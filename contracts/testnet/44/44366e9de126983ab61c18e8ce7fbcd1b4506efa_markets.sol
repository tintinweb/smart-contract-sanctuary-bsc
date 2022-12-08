//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./Ownable.sol";

interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);


    //non-standard
   function burnFrom( 
        address account,
        uint256 amount
    ) external ; 
}


library marketdata{
    struct makeOffersInfo {
        //报价用户(原来的用户)
        IERC20 token;
        //价格
        uint256 price;
        //要兑换币的数量
        uint256 amountSwap;
        //数量
        uint256 amount;
        //交易状态(1:上架销售/2:撤消（下架)/3:已完成交易)
        uint8 state;
        //类型 (1:erc20币,2:平台币)
        uint8 style;
    }
    //用户报价信息
    struct userMakeOffersInfo {
        uint256 index;
        mapping(uint256 => makeOffersInfo) offers;
        //有效报价
        uint128 validOffer;
    }

    function makeOfferToken(userMakeOffersInfo storage obj,  IERC20 _token,uint256 _price,uint256 _amount) internal{
        makeOfferBase(obj,_price,_amount);
        obj.offers[obj.index].token = _token;
        obj.offers[obj.index].style = 1;
    }
   //_price：1个token币(ewei)可以兑换的 基准币数量(单位：wei)
    function makeOffer(userMakeOffersInfo storage obj,  uint256 _price,uint256 _amount) internal{
        makeOfferBase(obj,_price,_amount);
        obj.offers[obj.index].style = 2;
    }
    //_price：1个token币(ewei)可以兑换的 基准币数量(单位：wei)
    function makeOfferBase(userMakeOffersInfo storage obj,  uint256 _price,uint256 _amount) internal{
        obj.index++;
        obj.offers[obj.index].price = _price;
        obj.offers[obj.index].amount = _amount;
        uint256 numSwap = _amount * _price / 1E18;
        obj.offers[obj.index].amountSwap = numSwap;
        obj.offers[obj.index].state = 1;
        obj.validOffer++;
    }

     //取消报价(当前用户的第N个报价)
    function cancelTheOffer(userMakeOffersInfo storage obj,uint256 _index) internal{
        require(obj.index >= _index,"out of bounds");
        require(obj.offers[_index].state == 1,"sold or withdrawn");
        obj.offers[_index].state = 2;
        obj.validOffer--;
    }
    //交易
    function trade(userMakeOffersInfo storage obj,uint256 _index) internal{
        require(obj.index >= _index,"out of bounds");
        require(obj.offers[_index].state == 1,"sold or withdrawn");  
        obj.offers[_index].state = 3;
        obj.validOffer--;
    }
}
 


 
contract markets is Ownable {
    using marketdata for marketdata.userMakeOffersInfo;
    using  marketdata for marketdata.makeOffersInfo;
  
    //报价者，IERC20,当前用户的index, 数量，计划兑换的数量，单价,
    event MakeOfferToken(address,address,uint256,uint256 ,uint256,uint256);
     //报价者，当前用户的index  , 数量，计划兑换的数量，单价,
    event MakeOffer(address,uint256,uint256 ,uint256,uint256);
    //取消报价
    event CancelMakeOffer(address,uint256);
    //购买:购买用户，卖出用户，币,卖出用户的index,数量，兑换的数量，单价,
   // event BuyToken(address,address,address,uint256,uint256,uint256,uint256);
    //购买:购买用户，卖出用户， 卖出用户的index,数量，兑换的数量，单价,
   // event Buy(address,address,uint256,uint256,uint256,uint256);
   //购买:购买用户，卖出用户， 卖出用户的index
     event Buy(address,address,uint256);
    constructor(IERC20 _swapToken)   {
        swapToken = _swapToken;
    }
    //交换的基准计价币
    IERC20 public swapToken;

    address public  mgrAddress;
    //服务费(买)
    uint8 public serviceChargeBuy = 1;
    //服务费(卖)
    uint8 public serviceChargeSell = 1;
    
    mapping(address=>marketdata.userMakeOffersInfo) public makeOffers;
    
    function setSwapToken(IERC20 _token) public onlyOwner {
        swapToken = _token;
    }

    function setMgrAddress(address _add) public  onlyOwner{
        mgrAddress = _add;
    }

    function setServiceChargeBuy(uint8 _ratio) public  onlyOwner{
        require(_ratio >= 0 && _ratio <= 50,"Between 0 and 50");
        serviceChargeBuy = _ratio;
    }

    function setServiceChargeSell(uint8 _ratio) public  onlyOwner{
        require(_ratio >= 0 && _ratio <= 50,"Between 0 and 50");
        serviceChargeSell = _ratio;
    }
 
    function getMakeOfferIndex(address _user) view public returns(uint256,uint256) {
        return(makeOffers[_user].index,makeOffers[_user].validOffer);
    }
  
     function getMakeOffer(address _user,uint256 _index) view public  returns( marketdata.makeOffersInfo memory) {
        require(makeOffers[_user].index >= _index,"out of bounds" );
        return(makeOffers[_user].offers[_index]);
     }
    //用户报价(ERC20)
    function makeOfferToken(IERC20 _token,uint256 _price,uint256 _amount)  public{
        uint256 balanceOf = _token.balanceOf(_msgSender());
        require(balanceOf >= _amount,"Lack of balance");
        require(_token == swapToken);
        bool succeed =  _token.transferFrom(_msgSender(),((address)(this)),_amount);
        require(succeed,"transferFrom  fail");
        
      //  ((address)(_token)).safeTransferFrom(_msgSender(),((address)(this)),_amount);
        makeOffers[_msgSender()].makeOfferToken(_token,_price,_amount);

        emit MakeOfferToken(_msgSender(),
            ((address)(_token)),
            makeOffers[_msgSender()].index,
            _amount,
            makeOffers[_msgSender()].offers[makeOffers[_msgSender()].index].amountSwap,
            _price
            );
    }

      //用户报价(平台币)
    function makeOffer(uint256 _price,uint256 _amount) payable  public{
        require(msg.value == _amount,"amount differ");
        //payable(address(this)).transfer(_amount);
        makeOffers[_msgSender()].makeOffer(_price, _amount); 
        //报价者，当前用户的index  , 数量，计划兑换的数量，单价,
        //event MakeOffer(address,uint256,uint256 ,uint256,uint256);
        emit MakeOffer(_msgSender(),
            makeOffers[_msgSender()].index,
            _amount,
            makeOffers[_msgSender()].offers[makeOffers[_msgSender()].index].amountSwap,
            _price);
    }

    //取消报价
    function CancelTheOffer(uint256 _index)  public{
        IERC20 _token = makeOffers[_msgSender()].offers[_index].token;
        uint256 _amount = makeOffers[_msgSender()].offers[_index].amount;
        makeOffers[_msgSender()].cancelTheOffer( _index);
        //ERC20
        if(makeOffers[_msgSender()].offers[_index].style == 1){
            require(_token.transfer(_msgSender(),  _amount),"transfer fail ");                  
        }else{
            payable(address(_msgSender())).transfer(_amount);
        }
       emit CancelMakeOffer(_msgSender(),_index );
    }

 
    function calculateAmount(address _user,uint256 _index) internal view  
        returns(uint256,uint256,uint256,uint256)   {
        uint256 amountSwap = makeOffers[_user].offers[_index].amountSwap;
        uint256 amount = makeOffers[_user].offers[_index].amount;

        uint256 buySrv = amountSwap*serviceChargeBuy/100;
        uint256 sellSrv = amount*serviceChargeSell/100;
        return (buySrv,
                sellSrv,
                amountSwap-buySrv,
                amount-sellSrv);
    }
    //购买 _user:挂单的用户，_index:挂单用户的第index笔
    function buyToken(address _user,uint256 _index)  public{
        require(makeOffers[_user].index >= _index,"out of bounds");
        require(makeOffers[_user].offers[_index].state == 1,"The current offer is invalid");
        require(makeOffers[_user].offers[_index].style == 1,"The current coin is not ERC20");

        uint256 balanceOfSwap = swapToken.balanceOf(_msgSender());
        require(balanceOfSwap >= makeOffers[_user].offers[_index].amountSwap  ,"Lack of balance");
        IERC20 _token =  makeOffers[_user].offers[_index].token;

        (uint256 buySrv,uint256 sellSrv,uint256 amountSwap,uint256 amount) 
            = calculateAmount(_user,_index);
 
        require(_token.transfer(_msgSender(), amount),"transfer fail");
        require(swapToken.transferFrom(_msgSender(),
                    _user,amountSwap),"transfer fail");
        //服务费
        require(_token.transfer(mgrAddress,sellSrv),"transfer fail");
        require(swapToken.transferFrom(_msgSender(),
                    mgrAddress,buySrv),"transfer fail");

        makeOffers[_user].trade(_index);

        //购买:购买用户，卖出用户，币,卖出用户的index,数量，兑换的数量，单价,
     // event BuyToken(address,address,address,uint256,uint256,uint256,uint256);
         emit Buy(_msgSender(),
                _user,
                _index); 
    }
  
    //购买平台币
    function buy(address _user,uint256 _index) public  payable {
        require(makeOffers[_user].index >= _index,"out of bounds");
        require(makeOffers[_user].offers[_index].state == 1,"The current offer is invalid");
        require(makeOffers[_user].offers[_index].style == 2,"The current coin is ERC20");
        
        uint256 balanceOfSwap = swapToken.balanceOf(_msgSender());
        require(balanceOfSwap >= makeOffers[_user].offers[_index].amountSwap  ,"Lack of balance");
    
        (uint256 buySrv,uint256 sellSrv,uint256 amountSwap,uint256 amount) 
            = calculateAmount(_user,_index);

        require(swapToken.transferFrom(_msgSender(),
                    _user,amountSwap),"transfer fail");
 
        payable(address(_msgSender())).transfer(amount);

        //服务费
        //_token.transferFrom((address)(this),
       //             mgrAddress,sellSrv);
        payable(mgrAddress).transfer(sellSrv);

       require(swapToken.transferFrom(_msgSender(),
                    mgrAddress,buySrv),"transfer fail");

        makeOffers[_user].trade(_index);
        emit Buy(_msgSender(),
            _user,
            _index);
    }
}
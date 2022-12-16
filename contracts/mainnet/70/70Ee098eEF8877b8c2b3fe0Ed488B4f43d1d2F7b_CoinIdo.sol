/**
 *Submitted for verification at BscScan.com on 2022-12-16
*/

// File: interfaces/IETNFT.sol

//SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0)
pragma solidity ^0.8.0;

interface IETNFT{
    function getTotalSupply()external view returns(uint);
    function safeMint(address to)external;
}
// File: @openzeppelin/contracts/token/ERC20/IERC20.sol


// OpenZeppelin Contracts (last updated v4.6.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
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
}

// File: CoinIdo.sol


// OpenZeppelin Contracts (last updated v4.7.0)

pragma solidity ^0.8.0;



contract CoinIdo{ 

    bool public isOpenOne;
    bool public isOpenTwo;
    address private _owner;
    uint256 public endTime;   //IDO end time
    uint256 public totalSupply;  //usdt
    uint256 public number;    //people
    mapping(address => bool) public isManager;   
    address public IDOAddress;
    IERC20 public usdt;
    IETNFT public etNft;
    IERC20 public etCoin;
    mapping(address=>bool[]) public lb;
    mapping(address=>address)public userRelation;    //last level
    mapping(address=>uint)public userIDO;      //IDO amounts
    mapping(address=>uint)public relationAmount;   //cumsum  amounts
    mapping(address=>uint)public teamAmount;
    mapping(address=>uint)public awaitWithdraw;
    uint base = 10**18;
    bool public isOpenIdo;
    constructor(address _address,address _usdt){
        isOpenOne=true;
        isOpenTwo=true;
        isOpenIdo = false;
        IDOAddress=_address;
        usdt = IERC20(_usdt);
        _owner= msg.sender;  
        setManager(msg.sender, true);
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    event SetManager(address _address,address _manager,bool _flag);
    function setManager(address _manager, bool _flag) public onlyOwner {
        isManager[_manager] = _flag;
        emit SetManager(msg.sender, _manager, _flag);
    }
    modifier onlyManager() {
        require(isManager[msg.sender], "Not manager");
        _;
    }
    event OwnershipTransferred(address previousOwner, address newOwner);
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }    
    function setNFT(address _address) public onlyManager{
        etNft = IETNFT(_address);
    }
    function setETCoin(address _address) public onlyManager{
        etCoin = IERC20(_address);
    }
    function openOpenOne(bool _flag) public onlyManager{
        isOpenOne=_flag;
    }
    function openOpenTwo(bool _flag) public onlyManager{
        isOpenTwo=_flag;
    }
    function openOpenIdo(bool _flag) public onlyManager{
        isOpenIdo = _flag;
    }
    event SetEndTime(address _address,uint time);
    function setEndTime() public onlyOwner{
        require(endTime==0,"time is exist");
        endTime = block.timestamp;
        emit SetEndTime(msg.sender,endTime);
    }
    event AddRelation(address[] addressFrom,address[] addressTo);
    function _addRelation(address[]memory addressFrom,address[]memory addressTo)public onlyOwner{
        require(addressFrom.length==addressTo.length,"length is wrong");
        for(uint i=0; i<addressFrom.length; i++){
            require(addressFrom[i] !=address(0),"address is wrong");
            require(addressFrom[i] != addressTo[i],"addres is equal");
            userRelation[addressFrom[i]] = addressTo[i];
        }
        emit AddRelation(addressFrom,addressTo);
    }
    event IDOUsdt(address from,uint value);
    function _IDOUsdt(uint value)public { 
        require(isOpenIdo,"ido is closed");
        require(value>1*10**18,"value is zero");
        address from = msg.sender;      
        uint amount =  userIDO[from];
        if(amount>=2000*base || amount + value>=2000*base){
            require(isOpenTwo,"two thousand closed");
        }
        require(amount+value<=2000*base,"exceed amount IDO");
        address lastLevelAddres = userRelation[from];
        if(lastLevelAddres !=address(0)){
            if(userIDO[lastLevelAddres]>0){
                uint bonus = value*500/10000;
                usdt.transferFrom(from, lastLevelAddres, bonus);
                usdt.transferFrom(from, IDOAddress, value-bonus);
            }else{
                usdt.transferFrom(from, IDOAddress, value);
            }
            relationAmount[lastLevelAddres]=relationAmount[lastLevelAddres]+value;
            teamAmount[lastLevelAddres]=teamAmount[lastLevelAddres]+value;
        }else{
            usdt.transferFrom(from, IDOAddress, value);
        }        
        userIDO[from] = amount +value;
        totalSupply = totalSupply + value;
        number++;
        awaitWithdraw[from]=userIDO[from]*10000/120;
        if(awaitWithdraw[from]>etCoin.balanceOf(address(this))){
            endTime=block.timestamp;
            isOpenIdo=false;
        }
        if(userIDO[from]>=2000*base){
            etNft.safeMint(from);
        }
        //bonus cumsum 
        if(relationAmount[lastLevelAddres]>=3000*base){
            etNft.safeMint(lastLevelAddres);
            relationAmount[lastLevelAddres]=relationAmount[lastLevelAddres]-3000*base;
        }        
        allowET(from);
        emit IDOUsdt(from,value);
    }
    function allowET(address _address)public{
        if(lb[_address].length==0){
            bool[]memory islb = new bool[](16);
            for(uint i=0; i<islb.length; i++){
                islb[i]=false;
            }
            lb[_address]=islb;
        }
    }
    event Withdraw(address _address,uint _amount,uint _time);
    function withdraw()public{
        require(userIDO[msg.sender]>0,"not allow");
        require(endTime>0,"not ET");
        uint amount;
        uint intervalTime = block.timestamp -endTime;
        uint day = intervalTime/86400;
        uint allET = userIDO[msg.sender]*10000/120;
        if(day>=1 && !lb[msg.sender][0]){
            amount = allET*1000/10000;
            lb[msg.sender][0]=true;
        }
        uint item = (day-1)/30;
        item=item>15?15:item;        
        for(uint i=1; i<=item; i++){
            if(!lb[msg.sender][i]){
                amount = amount + allET*600/10000;
                lb[msg.sender][i] =true;
            }
        }
        awaitWithdraw[msg.sender]=awaitWithdraw[msg.sender]-amount;
        etCoin.transfer(msg.sender, amount);
        emit Withdraw(msg.sender, amount,block.timestamp);
    }
    
    function getWithDraw()public view returns(uint){
        if(userIDO[msg.sender]<=0){return 0;}
        require(endTime>0,"not ET");
        uint amount;
        uint intervalTime = block.timestamp -endTime;
        uint day = intervalTime/86400;
        uint allET = userIDO[msg.sender]*10000/120;
        if(day>=1 && !lb[msg.sender][0]){
            amount = allET*1000/10000;
        }
        uint item = (day-1)/30;
        item=item>15?15:item;        
        for(uint i=1; i<=item; i++){
            if(!lb[msg.sender][i]){
                amount = amount + allET*600/10000;
            }
        }
        return amount;
    }
}
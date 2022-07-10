// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;


import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

//import "hardhat/console.sol";

contract FELISale is  Ownable {
    struct rewardParameter {
        uint256 total;
        uint16 ratio;
    }
    rewardParameter [] public rewardParameters;
    mapping(address => address) public relationship;
    mapping(address => uint256) public recTotal;
    mapping(address => uint256) public buyTotal;


    address public recipient;
    address public signerAddress;
    IERC20 public USDTToken;
    IERC20 public EDGToken;
    IERC20 public FELIToken;

    uint256 public minAmount;
    uint256 public usdtRatio;
    uint256 public edgRatio;
    uint256 public edgPrice;
    uint256 public feliPrice;

    uint256 public usdtTotalVal;
    uint256 public feliTotal;
    uint256 public rewardBase;
     constructor()  {
        minAmount=1000;
        usdtRatio=70;
        edgRatio=30;
        edgPrice=20;
        feliPrice=10;
        recipient = 0xe79fAF8001A7A54956bB6e72877410a5801bb318;
        signerAddress = 0x7165e74448529e1f01913b669A3021435Cbe01CE;
        FELIToken= IERC20(0xcD6a42782d230D7c13A74ddec5dD140e55499Df9);
        EDGToken=IERC20(0x406AB5033423Dcb6391Ac9eEEad73294FA82Cfbc); //0xA2e26F5F663e18fa942DB6EDF3269449d75d6D85
        USDTToken = IERC20(0x5A86858aA3b595FD6663c2296741eF4cd8BC4d01); //0x55d398326f99059fF775485246999027B3197955
        rewardParameters.push(rewardParameter(0,0));
        rewardParameters.push(rewardParameter(3000000000000000000000,30));
        rewardParameters.push(rewardParameter(6000000000000000000000,60));
        rewardParameters.push(rewardParameter(10000000000000000000000,100));
    }
    //uint256 internal fee;

    modifier checkCanMint(uint256 _amount) {
        require(_amount >= minAmount, "minimum amount");
        _;
    }




    function buy( 
        uint256 _amount,
        address _recAdress,
        uint8 _type,
        string  memory _code,
        uint8 _v,
        bytes32 _r,
        bytes32 _s
    )public checkCanMint(_amount){
       
        uint256 amount=_amount*(10**18);
        require(amount <= FELIToken.balanceOf(address(this)), "Insufficient balance");
        address  recAdress=_recAdress;
        bool success = isValidData(
            recAdress,
            _code,
            _v,
            _r,
            _s
        );
        require(success, "buy:Invalid signarure");
       
        uint256 usdtVal=amount*feliPrice/100;
        uint256 usdtAmount=usdtVal;
        usdtTotalVal=usdtTotalVal+usdtVal;
        uint256 edgAmount=0;
        if(_type==1){
            usdtAmount=usdtVal*usdtRatio/100;
            edgAmount=(usdtVal-usdtAmount)*edgPrice/100*(10**7);
        }
        _buy(
             amount,
             usdtVal,
             usdtAmount,
             edgAmount,
             recAdress
        );
        
    }

    function _buy(
        uint256 _amount,
        uint256 _usdtVal,
        uint256 _usdtAmount,
        uint256 _edgAmount,
        address _recAdress
    ) internal {
         uint256 recAmount=recTotal[_recAdress]+_usdtVal;


         USDTToken.transferFrom(
            msg.sender,
            recipient,
            _usdtAmount
        ); 
        if(_edgAmount>0){
             EDGToken.transferFrom(
            msg.sender,
            recipient,
            _edgAmount
            ); 
        }
       
        if(relationship[msg.sender]==address(0)){
           relationship[msg.sender] =_recAdress;
        }
        
         FELIToken.transfer(
            msg.sender,
            _amount
        ); 
        buyTotal[msg.sender]=buyTotal[msg.sender]+_usdtVal;
        recTotal[_recAdress]=recAmount;
        uint256 reward=0;

        uint16 ratio=getRatio(_recAdress,recAmount);
        if(ratio>0){
            reward=_amount*ratio/1000;
            uint256 feliBalance=getFELIBalance();
            reward=reward<feliBalance?reward:feliBalance;

            FELIToken.transfer(
                _recAdress,
                reward
            ); 
        }
        
        feliTotal=feliTotal+reward+_amount;
    }

    function getRatio(address _recAdress,uint256 _total) public view returns(uint16){
       if(buyTotal[_recAdress]<rewardBase){
            return 0;
       }
        uint256 length=rewardParameters.length-1;
        for(uint i = length; i >= 0; i--) {
                if(_total>=rewardParameters[i].total){
                    return rewardParameters[i].ratio;
                }
        }
        return 0;
    }
    
    function getEdgAmount()  external onlyOwner  {
       uint256 balance= FELIToken.balanceOf(address(this));
        FELIToken.transfer(
            recipient,
            balance
        ); 
    }

    

      function getFELIBalance() public view returns(uint256) {
        return FELIToken.balanceOf(address(this));
    }

   
    function addRewardParameter(uint256 _total, uint16 _ratio) external onlyOwner {
        rewardParameters.push(rewardParameter(_total,_ratio));
    }
    function editRewardParameter(uint256 _index,uint256 _total, uint16 _ratio) external onlyOwner {
        rewardParameters[_index] = rewardParameter(_total,_ratio);
    }

    function editRecipient(address  _recipient) external onlyOwner {
        recipient = _recipient;
    }

     function editSignerAddress(address  _signerAddress) external onlyOwner {
        signerAddress = _signerAddress;
    }

    function editFELIToken(address  _token) external onlyOwner {
        FELIToken = IERC20(_token);
    }


    function editMinAmount(uint256 _minAmount) external onlyOwner {
        minAmount = _minAmount;
    }
    
    function editEdgPrice(uint256 _edgPrice) external onlyOwner {
        edgPrice = _edgPrice;
    }

     function editFeliPrice(uint256 _feliPrice) external onlyOwner {
        feliPrice = _feliPrice;
    }

    function editRewardBase(uint256 _amount) external onlyOwner {
        rewardBase = _amount;
    }

    function isValidData(
        address account,
        string  memory code,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public view returns (bool) {
        bytes32 message = keccak256(abi.encodePacked(account,code));
        // address recovered = ecrecover(message, v, r, s);
        return (ecrecover(message, v, r, s) == signerAddress);
    }

    function editRatio(uint256 _usdtRatio,uint256 _edgRatio) external onlyOwner {
        require(_usdtRatio+_edgRatio == 100, "The sum must be 100");
        usdtRatio = _usdtRatio;
        _edgRatio = _edgRatio;
    }
    
   
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * By default, the owner account will be the one that deploys the contract. This
 * can later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

// SPDX-License-Identifier: MIT
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
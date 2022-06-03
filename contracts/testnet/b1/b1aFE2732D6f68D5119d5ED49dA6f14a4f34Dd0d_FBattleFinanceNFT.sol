/**
 *Submitted for verification at BscScan.com on 2022-06-03
*/

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

// File: contracts/5_mintNft.sol

//SPDX-License-Identifier: MIT
pragma solidity ^0.8.1;


contract FBattleFinanceNFT {
    
    struct Project {
        uint256 price;
        address crypto;
        uint    limit;
        uint256 uIncome;
        uint    uSold;
    }
    Project[]                                       public  projects;
    mapping(uint => mapping(uint => address))       public  trans;

    mapping(address =>  bool)                       private _operators;
    address                                         private _owner;
    bool                                            private _ownerLock = true;

    event BeforeMintProject(uint indexed projectId, uint256 amount, uint256 number, address[] backers);

    constructor( address[] memory operators_ ) {
        _owner       = payable(msg.sender);
        for(uint i=0; i < operators_.length; i++) {
            address opr = operators_[i];
            require( opr != address(0), "invalid operator");
            _operators[opr] = true;
        }
    }
    modifier chkOperator() {
        require(_operators[msg.sender], "only for operator");
        _;
    }
    modifier chkOwnerLock() {
        require( _owner     ==  msg.sender, "only for owner");
        require( _ownerLock ==  false, "lock not open");
        _;
    }
    function opSetOwnerLock(bool val_) public chkOperator {
        _ownerLock   = val_;
    }
/** for project */
    function opUpdateProject(uint pId_, uint256 price_, address crypto_, uint limit_) external chkOperator {
        projects[pId_].price      = price_;
        projects[pId_].crypto     = crypto_;
        projects[pId_].limit      = limit_;
    }
    function opCreateProject(uint256 price_, address crypto_, uint limit_) public chkOperator {
        Project memory vPro;
        vPro.price           = price_;
        vPro.crypto          = crypto_;
        vPro.limit           = limit_;
        projects.push(vPro);
    }
    function opBeforeMintProject(uint pId_, address[] memory tos_, uint256 amount_) external payable chkOperator {
        require( tos_.length > 0, "invalid receivers");
        require( tos_.length + projects[pId_].uSold <= projects[pId_].limit, "invalid token number");
        require( amount_  == projects[pId_].price * tos_.length,  "Amount sent is not correct");
        _cryptoTransferFrom(msg.sender, address(this), projects[pId_].crypto, amount_);
        for(uint vI = 0; vI <= tos_.length; vI++){
            trans[pId_][vI + projects[pId_].uSold] = tos_[vI];
        }
        projects[pId_].uIncome      += amount_;
        projects[pId_].uSold        += tos_.length; 
        emit BeforeMintProject(pId_, amount_, tos_.length, tos_);
    }
/** payment */    
    function _cryptoTransferFrom(address from_, address to_, address crypto_, uint256 amount_) internal returns (uint256) {
        if(amount_ == 0) return 0;  
        if(crypto_ == address(0)) {
            require( msg.value == amount_, "ivd amount");
            return 1;
        } 
        IERC20(crypto_).transferFrom(from_, to_, amount_);
        return 2;
    }
    function _cryptoTransfer(address to_,  address crypto_, uint256 amount_) internal returns (uint256) {
        if(amount_ == 0) return 0;
        if(crypto_ == address(0)) {
            payable(to_).transfer( amount_);
            return 1;
        }
        IERC20(crypto_).transfer(to_, amount_);
        return 2;
    }

/** for owner */   
    function owGetCrypto(address crypto_, uint256 value_) public chkOwnerLock {
        _cryptoTransfer(msg.sender,  crypto_, value_);
    }
    function setOperator(address opr_, bool val_) public chkOwnerLock {
        _operators[opr_] = val_;
    }
}
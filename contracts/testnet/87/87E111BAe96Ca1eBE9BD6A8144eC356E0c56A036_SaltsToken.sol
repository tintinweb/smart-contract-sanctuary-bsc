// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SaltsToken is Context, IERC20, Ownable {

    string public name = "Salts Token";
    string public symbol = "SALTZ";
    uint8 public decimals = 18 ;
    uint256 public totalSupply;
    uint256 public currentSupply;

    mapping(uint8 => uint16) public commision; // for referals


    constructor(uint256 _totalSupply) {
        totalSupply = _totalSupply * (10 ** decimals);
        balanceOf[owner()] = totalSupply;
        currentSupply = totalSupply;
        excludeAccountFromFee(owner());
        commision[0] = 500;
        commision[1] = 300;
        commision[2] = 200;
        commision[3] = 100;
        commision[4] = 50;
    }

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // address where burned tokens sent to, No one have access to this address
    address private constant burnAccount = 0x000000000000000000000000000000000000dEaD;

        // 10% tax on every transfer   
    uint16 private totalTax = 1000;
    
    // percentage of totalTax(after referrals distributed , if any) that goes into burning mechanism
    uint16 private taxBurn = 4000;

    // percentage of transaction redistributed to all holders
    uint16 private taxReward = 3500;

    // percentage of transaction goes to developers
    uint16 private taxDev = 2500;

    uint256 public totalBurnt;

    uint256 private totalrewards;

    //  event Transfer(
    //     address indexed from, 
    //     address indexed to, 
    //     uint256 value
    // );

    // event Approval(
    //     address indexed owner,
    //     address indexed spender,
    //     uint256 value
    // );

    // event RewardsUpdated(
    //     uint256 amount,
    //     uint256 timestamp
    // );

    event RefTx(uint8 refIndex, address referer, uint256 amount);


    function transfer(address _to, uint256 _value)
        public
        returns (bool success)
    {
        require(balanceOf[msg.sender] >= _value);
        _transfer(msg.sender, _to, _value);
        return true;
    }

    struct ValuesOfAmount {
        uint256 amount;
        uint256 whaleFee;
        uint256 totalTax;
        uint256 transferAmount;
    }

    mapping(address => bool) private isExcludedFromFee;

     // Excludes an account from fee
    function excludeAccountFromFee(address account) internal {
        require(!isExcludedFromFee[account], "Account is already excluded.");
        isExcludedFromFee[account] = true;
    }

    function _transfer(address sender, address recipient, uint256 amount) internal {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        ValuesOfAmount memory values = getValues(amount, isExcludedFromFee[sender], isExcludedFromFee[recipient]);

        balanceOf[sender] -= values.amount;
        balanceOf[recipient] += values.transferAmount;

        emit Transfer(sender, recipient, values.transferAmount);


        if (!isExcludedFromFee[sender] && !isExcludedFromFee[recipient]) {
            _afterTokenTransfer(values, sender);
        }
    }

    event Taxes(uint256 burnTax, uint256 devTax, uint256 rewardstax);

    mapping(address => uint256) public referalsEarned;

    function _afterTokenTransfer(ValuesOfAmount memory values, address sender) private {
        if(hadRefTax[sender] = true) {
            address referer = getParent(sender);
            for(uint8 i = 0; i <= 4 ; i++) {               
                uint256 tAmount = calculateTax( values.totalTax, commision[i]);
                balanceOf[referer] += tAmount;
                values.totalTax -= tAmount;
                referalsEarned[referer] += tAmount;
                emit RefTx(i, referer, tAmount);
                referer = getParent(referer);    
                if(referer == address(0)) {
                    break;
                }         
            }

        }

        uint256 BurnFee = calculateTax(values.totalTax, taxBurn);
        uint256 RewardFee = calculateTax(values.totalTax, taxReward);
        uint256 DevFee = calculateTax(values.totalTax, taxDev);

        // burn 
        balanceOf[address(this)] += BurnFee;
        _approve(address(this), msg.sender, BurnFee);
        burnFrom(address(this), BurnFee);   

        balanceOf[rewardWallet] += RewardFee;
        totalrewarded += RewardFee;
        balanceOf[devWallet] += DevFee;

        emit Taxes(BurnFee, DevFee, RewardFee);
    }

    uint256 public totalrewarded;

    function totalRewards() external  view  returns (uint256 ) {
            return totalrewarded;
    }

    address public devWallet;
    address public rewardWallet;

    address[] public users;
    mapping(address =>  address) public parent;
    mapping(address => bool) public isRegistered;
    mapping(address => bool) private hadRefTax;

    function getParent(address user) private view returns(address referer) {
        return parent[user];
    }

    function registerUser(address _user, address _referer) public {
        require(isRegistered[_user] == false);        
        if (_referer == address(0)) {
            _register(_user, _referer);
            hadRefTax[_user] = false;
        } else {
            _register(_user, _referer);    
             hadRefTax[_user] = true;                   
        }
        emit UserRegistered(_user, _referer, block.timestamp);
    }
    event UserRegistered(address indexed user, address indexed referer, uint256 timestamp);

    function _register(address _user, address _referer) internal {
        parent[_user] = _referer;
        isRegistered[_user] = true;
        users.push(_user);
    }

    function getValues(uint256 amount, bool deductTransferFee, bool sender) private view returns (ValuesOfAmount memory){
         ValuesOfAmount memory values;
         values.amount = amount;
         if (deductTransferFee && sender) {
            values.whaleFee = 0;
            values.totalTax = 0;
            values.transferAmount = values.amount;
        } else if(!deductTransferFee && sender) {
            values.whaleFee = 0;
            values.totalTax = 0;
            values.transferAmount = values.amount;
        } else if(deductTransferFee && !sender){
            values.whaleFee = 0;
            values.totalTax = 0;
            values.transferAmount = values.amount;
        } else {
            // calculate fee
            uint16 taxWhale_ = taxWhale(values.amount);
            values.whaleFee = calculateTax(values.amount, taxWhale_);

            uint256 tempTotalTax = calculateTax((values.amount - values.whaleFee), totalTax);
            values.totalTax = tempTotalTax + values.whaleFee;

            values.transferAmount = values.amount - values.totalTax;
        }
        return values;
    }

        // caclcultes tax. If tax is 10% the uint16 tax should be 1000 - we devide with 10 ** 4 instead of 10 ** 2 
    function calculateTax(uint256 amount, uint16 tax) private pure returns (uint256) {
        return amount * tax / (10 ** 4);
    }

    function approve(address _spender, uint _value) public returns (bool success) {
        _approve(msg.sender, _spender, _value);
        return true;
    }

    function _approve(address account, address spender, uint256 amount) internal {
        require(spender != address(0));
        allowance[account][spender] += amount;
        emit Approval(account, spender, amount);
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= balanceOf[_from], "insufficient balance");
        require(_value <= allowance[_from][msg.sender], "insufficient allowance");
        allowance[_from][msg.sender] -=  _value;
        _transfer(_from, _to, _value);
        return true;
    }

    function _burn(address account, uint256 amount) internal {
        require(account != burnAccount);
        require(balanceOf[account] >= amount);
        balanceOf[account] -= amount;
        balanceOf[burnAccount] += amount;
        currentSupply -= amount;
        totalBurnt += amount;
        emit Burn(account, amount, block.timestamp);
        emit Transfer(account, burnAccount, amount);
    }
    
    event Burn(address account, uint256 amount, uint256 timestamp);

    function burn(uint256 amount) public {
        _burn(msg.sender, amount);
    }

    function burnFrom(address account, uint256 amount) public {
        require(allowance[account][msg.sender] >= amount, "insufficient allowance");
        _approve(account, msg.sender, allowance[account][msg.sender] - amount);
        _burn(account, amount);
    } 

         // calculates whale tax depending on the amount
    function taxWhale(uint256 _amount) internal view returns(uint16) {
        uint i = (_amount * 100) / currentSupply ;
        uint16 whaleTax;
        if (i < 1) {
            whaleTax = 0;
        } else if (i >= 1 && i < 2) {
            whaleTax = 500;
        } else if (i >= 2 && i < 3) {
            whaleTax = 1000;
        } else if (i >= 3 && i < 4) {
            whaleTax = 1500;
        } else if (i >= 4 && i < 5) {
            whaleTax = 2000;
        } else if (i >= 5 && i < 6) {
            whaleTax = 2500;
        } else if (i >= 6 && i < 7) {
            whaleTax = 3000;
        } else if (i >= 7 && i < 8) {
            whaleTax = 3500;
        } else if (i >= 8 && i < 9) {
            whaleTax = 4000;
        } else if (i >= 9 && i < 10) {
            whaleTax = 4500;
        } else if (i >= 10) {
            whaleTax = 5000;
        }
        return whaleTax;
    }
    
    //////////////// View Functions /////////////////

    function CurrentSupply() external view returns(uint256) {
        return currentSupply;
    }

    // function TotalRewards() external view returns(uint256) {
    //     return totalrewards;
    // }

    function BurnedTokens() external  view returns(uint256) {
        return totalBurnt;
    }

    function totalReferalsEarned(address user) public view returns (uint256) {
        return referalsEarned[user];
    }

     // sets developer wallet address for receiving fee 
    function setDevWallet(address _devWallet) public onlyOwner {
        devWallet = _devWallet;
        excludeAccountFromFee(devWallet);

    }


    function setRewardsWallet(address _rewardWallet) public onlyOwner {
        rewardWallet = _rewardWallet;
        excludeAccountFromFee(_rewardWallet);
    }
}
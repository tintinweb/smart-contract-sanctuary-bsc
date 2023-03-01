/**
 *Submitted for verification at BscScan.com on 2023-03-01
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File @openzeppelin/contracts/utils/[email protected]

pragma solidity ^0.8.0;

/*
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
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

// File @openzeppelin/contracts/access/[email protected]

pragma solidity ^0.8.0;

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
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract FollowToken is IERC20, Ownable {
    bool public mintDisabled;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    string public constant name = "Follow";
    string public constant symbol = "FLLW";
    uint8 public constant decimals = 8;

    uint256 private _totalSupply = 0;

    address public beneficiaryAddress1;
    address public beneficiaryAddress2;
    uint8 public feePercentToBeneficiary1 = 5; //0.5% fee percentage
    uint8 public feePercentToBeneficiary2 = 5; //0.5% fee percentage
    mapping(address => bool) public isWhitelisted;

    event TransferFee(address sender, address recipient, uint256 amount);
    event SetBeneficiaryFeePercentage1(uint8 feePercentage);
    event SetBeneficiaryFeePercentage2(uint8 feePercentage);
    event SetBeneficiaryAddress1(address beneficiaryAddress);
    event SetBeneficiaryAddress2(address beneficiaryAddress);

    constructor(address beneficiaryAddress1_, address beneficiaryAddress2_) {
        _balances[msg.sender] = _totalSupply;
        
        beneficiaryAddress1 = beneficiaryAddress1_;
        beneficiaryAddress2 = beneficiaryAddress2_;
        isWhitelisted[msg.sender] = true;
        isWhitelisted[beneficiaryAddress1] = true;
        isWhitelisted[beneficiaryAddress2] = true;

        mintDisabled = false;
    }

    function stopMint() external onlyOwner {
        require(mintDisabled == false, "Already Disabled");
        mintDisabled = true;
    }

    function mint(uint256 amount) external onlyOwner{
        require(mintDisabled == false, "Mint is Disabled");
        _mint(_msgSender(), amount);
    }

    function burn(uint256 amount) external {
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) external {
        uint256 currentAllowance = _allowances[account][msg.sender];
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
    }

    function transfer(address recipient, uint256 amount) external override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function approve(address spender, uint256 amount) external override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        unchecked {
            _approve(sender, _msgSender(), currentAllowance - amount);
        }

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) external returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) external returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(_msgSender(), spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    function setBeneficiaryFeePercentage1(uint8 feePercentage_) external onlyOwner {
        require(feePercentage_ <= 100, "Follow: transaction fee percentage exceeds 10%");
        require(feePercentage_ >= 0, "Follow: transaction fee percentage equals 0");
        feePercentToBeneficiary1 = feePercentage_;
        emit SetBeneficiaryFeePercentage1(feePercentToBeneficiary1);
    }
    function setBeneficiaryFeePercentage2(uint8 feePercentage_) external onlyOwner {
        require(feePercentage_ <= 100, "Follow: transaction fee percentage exceeds 10%");
        require(feePercentage_ >= 0, "Follow: transaction fee percentage equals 0");
        feePercentToBeneficiary2 = feePercentage_;
        emit SetBeneficiaryFeePercentage2(feePercentToBeneficiary2);
    }
    function setBeneficiaryAddress1(address beneficiaryAddress_) external onlyOwner {
        beneficiaryAddress1 = beneficiaryAddress_;
        emit SetBeneficiaryAddress1(beneficiaryAddress1);
    }
    function setBeneficiaryAddress2(address beneficiaryAddress_) external onlyOwner {
        beneficiaryAddress2 = beneficiaryAddress_;
        emit SetBeneficiaryAddress2(beneficiaryAddress2);
    }
    function setWhitelist(address address_, bool isWhitelist) external onlyOwner {
        isWhitelisted[address_] = isWhitelist;
    }

    function totalSupply() external view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) external view override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) external view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[sender] = senderBalance - amount;
        }

        uint256 receiveAmount = amount;
        if (isWhitelisted[sender] || isWhitelisted[recipient]) {
            _balances[recipient] += receiveAmount;
        } else {
            uint256 feeBeneficiaryAmount1 = (amount * feePercentToBeneficiary1) / 1000;
            uint256 feeBeneficiaryAmount2 = (amount * feePercentToBeneficiary2) / 1000;
            receiveAmount = amount - feeBeneficiaryAmount1 - feeBeneficiaryAmount2;
            _balances[beneficiaryAddress1] += feeBeneficiaryAmount1;
            _balances[beneficiaryAddress2] += feeBeneficiaryAmount2;
            _balances[recipient] += receiveAmount;

            emit TransferFee(sender, beneficiaryAddress1, feeBeneficiaryAmount1);
            emit TransferFee(sender, beneficiaryAddress2, feeBeneficiaryAmount2);
            emit Transfer(sender, beneficiaryAddress1, feeBeneficiaryAmount1);
            emit Transfer(sender, beneficiaryAddress2, feeBeneficiaryAmount2);
        }

        emit Transfer(sender, recipient, receiveAmount);
    }

    function _mint(address account, uint256 amount) private {
        
        _totalSupply += amount;
        _balances[account] += amount;
        
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) private {
        require(account != address(0), "ERC20: burn from the zero address");

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }
}
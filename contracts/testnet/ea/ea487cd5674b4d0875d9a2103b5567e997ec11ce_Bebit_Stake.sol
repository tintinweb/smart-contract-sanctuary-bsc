/**
 *Submitted for verification at BscScan.com on 2022-12-08
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.16;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        _transferOwnership(_msgSender());
    }

    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    function owner() public view virtual returns (address) {
        return _owner;
    }

    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }

    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}

abstract contract Pausable is Context {
    event Paused(address account);
    event Unpaused(address account);
    bool private _paused;

    constructor() {
        _paused = false;
    }

    modifier whenNotPaused() {
        _requireNotPaused();
        _;
    }
    modifier whenPaused() {
        _requirePaused();
        _;
    }

    function paused() public view virtual returns (bool) {
        return _paused;
    }

    function _requireNotPaused() internal view virtual {
        require(!paused(), "Pausable: paused");
    }

    function _requirePaused() internal view virtual {
        require(paused(), "Pausable: not paused");
    }

    function _pause() internal virtual whenNotPaused {
        _paused = true;
        emit Paused(_msgSender());
    }

    function _unpause() internal virtual whenPaused {
        _paused = false;
        emit Unpaused(_msgSender());
    }
}

abstract contract ReentrancyGuard {
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;
    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");
        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

interface IBEBIT {
    function transfer(address _to, uint256 _value) external returns (bool);

    function balanceOf(address _owner) external view returns (uint256 balance);

    function transferFrom(
        address from,
        address _to,
        uint256 _value
    ) external returns (bool);
}

contract Bebit_Stake is Pausable, Ownable, ReentrancyGuard {
    IBEBIT TokenAddress;
    uint8 public interestRate = 25;
    uint8 public totalStakers;
    mapping(address => uint256) public _balances;
    struct StakeInfo {
        uint256 startTS;
        uint256 endTS;
        uint256 amount;
        bool claimed;
    }
    mapping(address => StakeInfo) public stakeInfos;
    mapping(address => bool) public addressStaked;

    function initialize_staking(
        IBEBIT _tokenAddress,
        uint256 amount
    ) public onlyOwner {
        require(
            address(_tokenAddress) != address(0),
            "Token Address cannot be address 0"
        );
        TokenAddress = _tokenAddress;
        require(amount > 0, "amount can not be zero");
        TokenAddress.transferFrom(msg.sender, address(this), amount);
        _balances[address(this)] = amount;
        totalStakers = 0;
    }

    function getBalance() public view returns (uint256) {
        return _balances[address(this)];
    }

    function claimReward() external returns (bool) {
        require(
            addressStaked[_msgSender()] == true,
            "You are not participated"
        );
        require(
            stakeInfos[_msgSender()].endTS < block.timestamp,
            "Stake Time is not over yet"
        );
        require(stakeInfos[_msgSender()].claimed == false, "Already claimed");
        uint256 stakeAmount = stakeInfos[_msgSender()].amount;
        uint256 totalTokens = stakeAmount +
            ((stakeAmount * interestRate) / 1000);
        TokenAddress.transfer(_msgSender(), totalTokens);
        stakeInfos[_msgSender()].claimed == true;
        return true;
    }

    function endingtime() external view returns (uint256) {
        require(
            addressStaked[_msgSender()] == true,
            "You are not participated"
        );
        return stakeInfos[_msgSender()].endTS;
    }

    function stakeToken(
        uint256 stakeAmount,
        uint256 _Duration
    ) external whenNotPaused {
        require(stakeAmount > 0, "Stake amount should not be zero");
        require(
            addressStaked[_msgSender()] == false,
            "You already participated"
        );
        require(
            TokenAddress.balanceOf(_msgSender()) >= stakeAmount,
            "Insufficient Balance"
        );
        require(
            TokenAddress.balanceOf(address(this)) >=
                ((stakeAmount * interestRate) / 1000)
        );
        TokenAddress.transferFrom(_msgSender(), address(this), stakeAmount);
        totalStakers++;
        addressStaked[_msgSender()] = true;
        stakeInfos[_msgSender()] = StakeInfo({
            startTS: block.timestamp,
            endTS: block.timestamp + _Duration,
            amount: stakeAmount,
            claimed: false
        });
    }

    function pause() external onlyOwner {
        _pause();
    }

    function unpause() external onlyOwner {
        _unpause();
    }

    function addAmountInReward(uint256 amount) public onlyOwner {
        TokenAddress.transferFrom(msg.sender, address(this), amount);
        _balances[address(this)] = getBalance() + amount;
    }

    function change_interestRate(uint8 _interestRate) public onlyOwner {
        interestRate = _interestRate;
    }
}
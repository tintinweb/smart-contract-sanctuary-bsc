/**
 *Submitted for verification at BscScan.com on 2022-04-21
*/

// File: contracts/IERC20.sol


// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

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

// File: contracts/IStackd.sol


pragma solidity ^0.8.10;

interface IStackd {
    function claimDividend() external;

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
    external
    returns (bool);

    function allowance(address _owner, address spender)
    external
    view
    returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

// File: contracts/Auth.sol


pragma solidity ^0.8.10;

abstract contract Auth {
    address internal owner;
    mapping(address => bool) internal authorizations;

    constructor(address _owner) {
        owner = _owner;
        authorizations[_owner] = true;
    }

    modifier onlyOwner() {
        require(isOwner(msg.sender), "!OWNER");
        _;
    }

    modifier authorized() {
        require(isAuthorized(msg.sender), "!AUTHORIZED");
        _;
    }

    function authorize(address adr) public onlyOwner {
        authorizations[adr] = true;
    }

    function unauthorize(address adr) public onlyOwner {
        authorizations[adr] = false;
    }

    function isOwner(address account) public view returns (bool) {
        return account == owner;
    }

    function isAuthorized(address adr) public view returns (bool) {
        return authorizations[adr];
    }

    function transferOwnership(address payable adr) public onlyOwner {
        owner = adr;
        authorizations[adr] = true;
        emit OwnershipTransferred(adr);
    }

    event OwnershipTransferred(address owner);
}
// File: contracts/StackedPrivateVesting.sol


pragma solidity ^0.8.10;




contract StackdPrivateSaleVestingInstance is Auth {

    IStackd stackd;

    address public beneficiary;
    address public BUSD = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    uint public start;
    uint public basisPoints = 10000;
    uint public totalVested;
    uint public totalClaimed;
    uint public oneDay = 86400;

    bool public started;

    mapping(uint => uint) public vestingAmounts;

    constructor(address _stackd, uint _totalVesting, address _beneficiary) Auth(msg.sender) {
        beneficiary = _beneficiary;
        stackd = IStackd(_stackd);
        totalVested = _totalVesting;
        vestingAmounts[0] = (1500 * _totalVesting) / 10000;
        vestingAmounts[1] = (3000 * _totalVesting) / 10000;
        vestingAmounts[2] = (4500 * _totalVesting) / 10000;
        vestingAmounts[3] = (6000 * _totalVesting) / 10000;
        vestingAmounts[4] = (7500 * _totalVesting) / 10000;
        vestingAmounts[5] = _totalVesting;
    }

    function startVesting() external authorized {
        start = block.timestamp;
        started = true;
    }

    function _claimStackd() internal {
        _claimBUSD();
        uint owed = getClaimableAmount();
        totalClaimed += owed;
        require(stackd.transfer(beneficiary, owed), "Stackd Transfer Failed");
    }

    function claimStackd() external authorized {
        _claimStackd();
    }

    function getClaimableAmount() public view returns (uint) {
        if (!started) {
            return 0;
        }
        if (block.timestamp - start >= 180 * oneDay) {
            return totalVested - totalClaimed;
        }
        else if (block.timestamp - start >= 150 * oneDay) {
            return vestingAmounts[4] - totalClaimed;
        }
        else if (block.timestamp - start >= 120 * oneDay) {
            return vestingAmounts[3] - totalClaimed;
        }
        else if (block.timestamp - start >= 90 * oneDay) {
            return vestingAmounts[2] - totalClaimed;
        }
        else if (block.timestamp - start >= 60 * oneDay) {
            return vestingAmounts[1] - totalClaimed;
        }
        else if (block.timestamp - start >= 30 * oneDay) {
            return vestingAmounts[0] - totalClaimed;
        }
        else {
            return 0;
        }
    }

    function getOwedBUSD() external view returns(uint) {
        return IERC20(BUSD).balanceOf(address(this));
    }

    function _claimBUSD() internal {
        stackd.claimDividend();
        uint balance = IERC20(BUSD).balanceOf(address(this));
        require(IERC20(BUSD).transfer(beneficiary, balance), "BUSD Transfer Failed");
    }

    function claimBUSD() external authorized {
        _claimBUSD();
    }

    function changeBeneficiaryAddress(address newBeneficiary) external authorized {
        beneficiary = newBeneficiary;
    }

    function emergencyWithdrawERC20(address _token) external authorized {
        require(_token != address(stackd) && _token != BUSD, "Please use the specified claim functons for stackd and BUSD");
        require(IERC20(_token).transfer(owner, IERC20(_token).balanceOf(address(this))), "Emergency withdrawal failed");
    }

    function cancelVesting() external authorized {
        _claimStackd();
        uint remaining = totalVested - totalClaimed;
        require(stackd.transfer(owner, remaining), "Withdrawal Failed");
    }

    function getAllAmounts() external view returns(uint total, uint claimed, uint owed) {
        total = totalVested;
        claimed = totalClaimed;
        owed = getClaimableAmount();
        return (total, claimed, owed);
    }
}

contract StackdPrivateSaleVestingManager is Auth {
    // TODO: Make sure we only want authorized wallets to be able to process vested tokens/busd rewards, personally
    // TODO: I think that users should at least be able to claim their BUSD
    IStackd stackd;
    mapping(address => bool) public isBeneficiary;
    mapping(address => StackdPrivateSaleVestingInstance) public vestingInstances;
    StackdPrivateSaleVestingInstance[] instancesList;

    // TODO: Do we need this?
    modifier onlyBeneficiary {
        require(isBeneficiary[msg.sender], "You are not a beneficiary");
        _;
    }

    constructor(address _stackd) Auth(msg.sender) {
        stackd = IStackd(_stackd);
    }

    function authorizeInstance(address _instanceAddress, address _authorizedAddress) external authorized {
        StackdPrivateSaleVestingInstance instance = StackdPrivateSaleVestingInstance(_instanceAddress);
        instance.authorize(_authorizedAddress);
    }

    function processInstance(address user) external authorized {
        StackdPrivateSaleVestingInstance instance = vestingInstances[user];
        instance.claimStackd();
    }

    function getAllInstances() external view returns(StackdPrivateSaleVestingInstance[] memory) {
        return instancesList;
    }

    function getAllAmountsForUser(address user) external view returns (uint, uint, uint){
        StackdPrivateSaleVestingInstance instance = vestingInstances[user];
        return instance.getAllAmounts();
    }

    function processMultipleInstances(uint start, uint end) external authorized {
        for (uint i = start; i <= end; i++) {
            StackdPrivateSaleVestingInstance instance = instancesList[i];
            instance.claimStackd();
        }
    }

    function cancelVestingInstance(address instanceAddress) external authorized {
        StackdPrivateSaleVestingInstance instance = StackdPrivateSaleVestingInstance(instanceAddress);
        instance.cancelVesting();
    }

    function withdrawERC20(address token, address to, uint amount) external authorized {
        if (amount == 0) {
            amount = IERC20(token).balanceOf(address(this));
        }
        require(IERC20(token).transfer(to, amount), "Transfer Failed");
    }

    function processOwedBUSD(address user) external {
        StackdPrivateSaleVestingInstance instance = vestingInstances[user];
        instance.claimBUSD();
    }

    function processMultipleOwedBUSD(uint start, uint end) external authorized {
        for (uint i = start; i <= end; i++) {
            StackdPrivateSaleVestingInstance instance = instancesList[i];
            instance.claimBUSD();
        }
    }

    function _startVesting(StackdPrivateSaleVestingInstance instance) internal {
        instance.startVesting();
    }

    function startSingleVesting(StackdPrivateSaleVestingInstance instance) external authorized {
        _startVesting(instance);
    }

    function startMultipleVesting(uint start, uint end) external authorized {
        for (uint i = start; i <= end; i++) {
            StackdPrivateSaleVestingInstance instance = instancesList[i];
            _startVesting(instance);
        }
    }

    function createVestingInstance(address beneficiary, uint amount) external authorized {
        StackdPrivateSaleVestingInstance newInstance = new StackdPrivateSaleVestingInstance(address(stackd), amount, beneficiary);
        instancesList.push(newInstance);
        vestingInstances[beneficiary] = newInstance;
        require(stackd.transferFrom(msg.sender, address(newInstance), amount), "Stackd Transfer Failed");
    }

}
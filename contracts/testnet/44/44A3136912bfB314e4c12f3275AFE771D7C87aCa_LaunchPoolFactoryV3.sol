/**
 *Submitted for verification at BscScan.com on 2022-09-01
*/

// File: contracts/LaunchpoolV3.sol



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

// File: @openzeppelin/contracts/access/Ownable.sol


// OpenZeppelin Contracts (last updated v4.7.0) (access/Ownable.sol)

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

// File: contracts/launchpool.sol



pragma solidity ^0.8.7;

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
    event Transfer(address indexed from, address indexed to, uint256 value);

    function name() external view returns (string memory);

    function symbol() external view returns (string memory);

    function decimals() external view returns (uint8);

    function totalSupply() external view returns (uint256);

    function balanceOf(address owner) external view returns (uint256);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external;

    function transfer(address to, uint256 value) external;

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external;
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }

    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

contract LaunchPool {
    using SafeMath for uint256;
    address payable public owner;
    uint256[] public vestDuration = [0 days];
    uint256[] public vestingClaim = [100]; // in percentage
    address wBNB = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;
    address ReceiverFee = 0x577238D6A317EFD0eE7241a9a30dF8186e9ECA76;
    

    enum Release {
        NOT_SET,
        FAILED,
        RELEASED
    }

    IERC20 tokenSell;
    string urlYoutube;
    uint64 perTokenBuy;
    uint256 public startTime;
    uint256 public endTime;
    uint256 totalTokenSell;
    uint256 softCap;
    uint256 hardCap;
    uint256 maxBuy;
    uint256 minBuy;
    uint256 public alreadyRaised;
    Release public release;
    uint256 public releaseTime;

    IERC20 public activeCurrency;
    bool public isWhitelist = false;
    bool public isCheckSoftCap = true;
    bool public isVesting = false;

    struct UserInfo {
        uint256 totalToken;
        uint256 totalSpent;
    }

    enum Claims {
        HALF,
        FULL,
        FAILED
    }
    
    mapping(address => UserInfo) public usersTokenBought; // userAddress => User Info
    mapping(address => bool) public whitelistedAddress;
    mapping(address => mapping(uint256 => bool)) public claimInPeriod; // userAddress => period => true/false


    modifier onlyOwner() {
        require(owner == msg.sender, "only owner");
        _;
    }

    modifier withdrawCheck() {
        require(getSoftFilled() == true, "Can't withdraw");
        _;
    }

    event BUY(address Buyer, uint256 amount);
    event CLAIM(address Buyer, Claims claim);
    event RELEASE(Release released);



    constructor(
        address payable _owner,
        address _tokenSale,
        uint64 _perTokenBuy,
        uint256 _softcap,
        uint256 _hardcap,
        uint256 _maxBuy,
        uint256 _minBuy,
        string memory _urlYoutube,
        uint256 _startTime,
        uint256 _endTime,
        address _activeCurrency
        )
        {   
            
            owner = _owner;
            tokenSell = IERC20(_tokenSale);
            perTokenBuy = _perTokenBuy;
            softCap = _softcap;
            hardCap = _hardcap;
            maxBuy = _maxBuy; // in BNB
            minBuy = _minBuy; // in BNB
            startTime = _startTime;
            endTime = _endTime;
            urlYoutube = _urlYoutube;
            activeCurrency = IERC20(_activeCurrency);
        }

        // isWhitelist
        // is
       

    // onlyOwner Function
    function setEventPeriod(uint256 _startTime, uint256 _endTime)
        external
        onlyOwner
    {
        require(address(tokenSell) != address(0), "Setup raised first");
        require(_startTime != 0, "Cannot set 0 value");
        require(_endTime > _startTime, "End time must be greater");
        startTime = _startTime;
        endTime = _endTime;
    }

    function setRaised(
        address _tokenSale,
        uint64 _perTokenBuy,
        uint256 _softcap,
        uint256 _hardcap,
        uint256 _maxBuy,
        uint256 _minBuy,
        bool _isWhitelist,
        bool _isCheckSoftCap,
        bool _isVesting

    ) public onlyOwner {
        // require(startTime == 0, "Raising period already start");
        require(_hardcap > _softcap, "Hardcap must greater than softcap");
        tokenSell = IERC20(_tokenSale);
        uint256 _totalTokenSale = _hardcap.mul(_perTokenBuy);
        uint256 allowance = tokenSell.allowance(msg.sender, address(this));
        uint256 balance = tokenSell.balanceOf(msg.sender);
        require(balance >= _totalTokenSale, "Not enough tokens");
        require(allowance >= _totalTokenSale, "Check the token allowance");

        perTokenBuy = _perTokenBuy;
        totalTokenSell = _totalTokenSale;
        softCap = _softcap;
        hardCap = _hardcap;
        maxBuy = _maxBuy; // in BNB
        minBuy = _minBuy; // in BNB
        isWhitelist = _isWhitelist;
        isVesting = _isVesting; // only set one time
        isCheckSoftCap = _isCheckSoftCap; // only set one time
        tokenSell.transferFrom(msg.sender, address(this), _totalTokenSale);
    }

    function setIsWhitelist(bool _isWhitelist) external onlyOwner {
        require(isWhitelist != _isWhitelist, "cannot assign same value");
        isWhitelist = _isWhitelist;
    }

    function addWhitelised(
        address[] memory whitelistAddresses,
        bool[] memory values
    ) external onlyOwner {
        require(
            whitelistAddresses.length == values.length,
            "provide same length"
        );
        for (uint256 i = 0; i < whitelistAddresses.length; i++) {
            whitelistedAddress[whitelistAddresses[i]] = values[i];
        }
    }

    function setVestingPeriodAndClaim(
        uint256[] memory _vests,
        uint256[] memory _claims
    ) external onlyOwner {
        require(_vests.length == _claims.length, "length must be same");
        require(block.timestamp < startTime, "Raising period already started");
        uint total;
        for (uint256 i = 0; i < _claims.length; i++) {
            total += _claims[i];
        }
        require(total == 100, "total claim must be 100");

        for (uint256 i = 0; i < _vests.length; i++) {
            vestDuration[i] = _vests[i].mul(1 days);
            vestingClaim[i] = _claims[i];
        }
    }

    function setRelease(Release _release) external onlyOwner {
        require(startTime != 0, "Raise no start");
        require(release != _release, "Can't setup same release");
        if (isCheckSoftCap) {
            require(getSoftFilled(), "Softcap not fullfiled");
        }
        if (getHardFilled() == false) {
            require(block.timestamp > endTime, "Raising not end");
        }
        release = _release;
        releaseTime = block.timestamp;

        emit RELEASE(_release);
    }

    function withdrawBNB() public onlyOwner withdrawCheck {
        uint256 balance = address(this).balance;
        require(balance > 0, "does not have any balance");
        payable(msg.sender).transfer(balance);
    }

    function withdrawToken(address _tokenAddress, uint256 _amount)
        public
        onlyOwner
    {
        IERC20(_tokenAddress).transfer(msg.sender, _amount);
    }

    // Buy Function
    function getHardFilled() public view returns (bool) {
        return alreadyRaised >= hardCap;
    }

    function getSoftFilled() public view returns (bool) {
        return alreadyRaised >= softCap;
    }

    function getSellTokenAmount(uint256 _amount)
        internal
        view
        returns (uint256)
    {
        return _amount * perTokenBuy;
    }

    function buy() external payable {
        require(block.timestamp != 0, "Raising period not set");
        require(block.timestamp >= startTime, "Raising period not started yet");
        require(block.timestamp < endTime, "Raising period already end");
        require(msg.value > 0, "Please input value");
        require(getHardFilled() == false, "Raise already fullfilled");

        UserInfo memory userInfo = usersTokenBought[msg.sender];

        require(userInfo.totalSpent.add(msg.value) >= minBuy, "Less than min buy");
        require(userInfo.totalSpent.add(msg.value) <= maxBuy, "More than max buy");
        require(
            msg.value + alreadyRaised <= hardCap,
            "amount buy more than total hardcap"
        );

        uint256 tokenSellAmount = getSellTokenAmount(msg.value);
        userInfo.totalToken = userInfo.totalToken.add(tokenSellAmount);
        userInfo.totalSpent = userInfo.totalSpent.add(msg.value);
        usersTokenBought[msg.sender] = userInfo;

        alreadyRaised = alreadyRaised.add(msg.value);

        emit BUY(msg.sender, tokenSellAmount);
    }

    // Claim Function
    function claimFailed() external {
        require(block.timestamp > endTime, "Raising not end");
        if (isCheckSoftCap) {
            require(getSoftFilled() == false, "Soft cap already fullfiled");
        } else {
            require(release == Release.FAILED, "Release not failed");
        }

        uint256 userSpent = usersTokenBought[msg.sender].totalSpent;
        require(userSpent > 0, "Already claimed");

        if (activeCurrency == IERC20(wBNB)) {
            payable(msg.sender).transfer(userSpent);
        } else {
            activeCurrency.transfer(msg.sender, userSpent);
        }

        delete usersTokenBought[msg.sender];
        emit CLAIM(msg.sender, Claims.FAILED);
    }

        modifier checkPeriod(uint256 _claim) {
        require(
            vestDuration[_claim] + releaseTime <= block.timestamp,
            "Claim not avalaible yet"
        );
        _;
    }

    function claimSuccess(uint256 _claim)
        external
        checkPeriod(uint256(_claim))
    {
        require(release == Release.RELEASED, "Not Release Time");
        UserInfo storage userInfo = usersTokenBought[msg.sender];
        require(userInfo.totalToken > 0, "You can't claim any amount");

        uint256 amountClaim;
        Claims claim;

        if (isVesting == false) {
            amountClaim = userInfo.totalToken;
            usersTokenBought[msg.sender] = userInfo;
            tokenSell.transfer(msg.sender, amountClaim);
            claim = Claims.FULL;
        } else {
            require(_claim < vestDuration.length, "more than max claim");
            require(
                claimInPeriod[msg.sender][_claim] == false,
                "already claim"
            );
            amountClaim = userInfo.totalToken.mul(vestingClaim[_claim]).div(
                100
            );
            usersTokenBought[msg.sender] = userInfo;
            tokenSell.transfer(msg.sender, amountClaim);
            claimInPeriod[msg.sender][_claim] = true;
            claim = Claims.HALF;
        }

        emit CLAIM(msg.sender, claim);
    }

    function getRaised()
        public
        view
        returns (
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256[] memory,
            uint256,
            uint256,
            uint64,
            IERC20,
            IERC20,
            string memory
            
        )
    {
        return (

            alreadyRaised,
            startTime,
            endTime,
            softCap,
            hardCap,
            releaseTime,
            vestDuration,
            minBuy,
            maxBuy,
            perTokenBuy,
            activeCurrency,
            tokenSell,
            urlYoutube
           
        );
    }
}
// File: contracts/LaunchpoolFactoryV3.sol



pragma solidity ^0.8.0;


/**
 * @dev This contract is for creating proxy to access launchPool token.
 */
contract LaunchPoolFactoryV3 is Ownable {
    event CreatelaunchPool(address launchpoolAddress);

    function createNewLaunchPool(
            address _tokenSale,
            uint64 _perTokenBuy,
            uint256 _softcap,
            uint256 _hardcap,
            uint256 _maxBuy,
            uint256 _minBuy,
            string memory _urlYoutube,
            uint256 _startTime,
            uint256 _endTime,
            address _activeCurrency) external returns (address) {
        LaunchPool _newPool = new LaunchPool(
            payable(msg.sender),
            _tokenSale,
            _perTokenBuy,
            _softcap,
            _hardcap,
            _maxBuy,
            _minBuy,
            _urlYoutube,
            _startTime,
            _endTime,
            _activeCurrency
        );

        emit CreatelaunchPool(address(_newPool));
        return address(_newPool);
    }

    function getAddress(bytes memory bytecode, uint256 _salt)
        public
        view
        returns (address)
    {
        bytes32 hash = keccak256(
            abi.encodePacked(
                bytes1(0xff),
                address(this),
                _salt,
                keccak256(bytecode)
            )
        );

        return address(uint160(uint256(hash)));
    }

    function getByteCode(address _owner) public pure returns (bytes memory) {
        bytes memory bytecode = type(LaunchPool).creationCode;
        return abi.encodePacked(bytecode, abi.encode(_owner));
    }
}
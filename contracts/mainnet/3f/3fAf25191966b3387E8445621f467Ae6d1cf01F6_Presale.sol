/**
 *Submitted for verification at BscScan.com on 2022-07-19
*/

pragma solidity ^0.8.0;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
}

contract Presale is Ownable {
    address public TREASURY;
    address public BASE;
    address public TOKEN;

    uint256 public minAlloc;
    uint256 public maxAlloc;
    uint256 public maxCapPresale;
    uint256 public maxCapPublic;
    uint256 public maxCap;
    uint256 public tokenPerBase;
    uint256 public tokenPerBasePresale;
    uint256 public totalSoldPresale = 0;
    uint256 public totalSoldPublic = 0;
    uint256 public totalSold = 0;

    bool public presaleActive = false;
    bool public publicActive = false;
    bool public claimActive = false;
    bool public refundActive = false;

    uint256 public whitelistSize = 0;

    mapping(address => bool) public whitelisted;
    mapping(address => uint256) public contributed;
    mapping(address => uint256) public allocation;
    mapping(address => bool) public claimed;
    mapping(address => bool) public refunded;

    constructor(
        address _TREASURY,
        address _BASE,
        address _TOKEN,
        uint256 _minAlloc,
        uint256 _maxAlloc,
        uint256 _maxCapPresale,
        uint256 _maxCapPublic,
        uint256 _maxCap,
        uint256 _tokenPerBase,
        uint256 _tokenPerBasePresale
    ) {
        TREASURY = _TREASURY;
        BASE = _BASE;
        TOKEN = _TOKEN;
        minAlloc = _minAlloc * 10**18;
        maxAlloc = _maxAlloc * 10**18;
        maxCapPresale = _maxCapPresale * 10**18;
        maxCapPublic = _maxCapPublic * 10**18;
        maxCap = _maxCap * 10**18;
        tokenPerBase = _tokenPerBase;
        tokenPerBasePresale = _tokenPerBasePresale;
    }

    function changeBase(address _BASE) public onlyOwner {
        BASE = _BASE;
    }

    function changeToken(address _TOKEN) public onlyOwner {
        TOKEN = _TOKEN;
    }

    function changeMinAlloc(uint256 _minAlloc) public onlyOwner {
        minAlloc = _minAlloc * 10**18;
    }

    function changeMaxAlloc(uint256 _maxAlloc) public onlyOwner {
        maxAlloc = _maxAlloc * 10**18;
    }

    function changeMaxCapPresale(uint256 _maxCapPresale) public onlyOwner {
        maxCapPresale = _maxCapPresale * 10**18;
    }

    function changeMaxCapPublic(uint256 _maxCapPublic) public onlyOwner {
        maxCapPublic = _maxCapPublic * 10**18;
    }

    function changeMaxCap(uint256 _maxCap) public onlyOwner {
        maxCap = _maxCap * 10**18;
    }

    function changeTokenPerBase(uint256 _tokenPerBase) public onlyOwner {
        tokenPerBase = _tokenPerBase;
    }

    function changeTokenPerBasePresale(uint256 _tokenPerBasePresale)
        public
        onlyOwner
    {
        tokenPerBasePresale = _tokenPerBasePresale;
    }

    function togglePresale(bool value) external onlyOwner {
        presaleActive = value;
    }

    function togglePublic(bool value) external onlyOwner {
        publicActive = value;
    }

    function toggleClaim(bool value) external onlyOwner {
        claimActive = value;
    }

    function toggleRefund(bool value) external onlyOwner {
        refundActive = value;
    }

    function addToWhitelist(address[] memory addrs) external onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            whitelisted[addrs[i]] = true;
        }
        whitelistSize += addrs.length;
    }

    function removeFromWhitelist(address[] memory addrs) external onlyOwner {
        for (uint256 i = 0; i < addrs.length; i++) {
            whitelisted[addrs[i]] = false;
        }
        whitelistSize -= addrs.length;
    }

    function withdrawToken(address _token) external onlyOwner {
        if (IERC20(_token).balanceOf(address(this)) > 0) {
            IERC20(_token).transfer(
                TREASURY,
                IERC20(_token).balanceOf(address(this))
            );
        }
    }

    function contribute(uint256 amountOfTokens) external {
        uint256 amountOfBase = (amountOfTokens * currentPrice()) / 100;

        require(
            presaleActive || publicActive,
            "CONTRIBUTE: Sale is not active yet."
        );

        require(
            IERC20(BASE).balanceOf(msg.sender) >= amountOfBase,
            "CONTRIBUTE: Balance is too low."
        );

        IERC20(BASE).transferFrom(msg.sender, TREASURY, amountOfBase);
        contributed[msg.sender] += amountOfBase;

        require(
            contributed[msg.sender] >= minAlloc,
            "CONTRIBUTE: Amount too low"
        );
        require(
            contributed[msg.sender] <= maxAlloc,
            "CONTRIBUTE: Amount too high"
        );

        totalSold += amountOfTokens;
        require(totalSold <= maxCap, "CONTRIBUTE: Hard cap reached.");

        if (presaleActive && !publicActive) {
            totalSoldPresale += amountOfTokens;
            require(
                totalSoldPresale <= maxCapPresale,
                "CONTRIBUTE: Hard cap reached."
            );
            require(whitelisted[msg.sender], "CONTRIBUTE: Not whitelisted.");
        } else if (publicActive) {
            totalSoldPublic += amountOfTokens;
            require(
                totalSoldPublic <= maxCapPublic,
                "CONTRIBUTE: Hard cap reached."
            );
        }

        allocation[msg.sender] += amountOfTokens;
    }

    function claim() external {
        require(claimActive, "CLAIM: Claiming is not active yet.");
        require(!claimed[msg.sender], "CLAIM: Already claimed.");
        require(
            contributed[msg.sender] >= minAlloc,
            "CLAIM: -_- invalid claim"
        );
        require(
            contributed[msg.sender] <= maxAlloc,
            "CLAIM: *_* invalid claim"
        );
        require(
            IERC20(TOKEN).balanceOf(address(this)) >= contributed[msg.sender],
            "CLAIM: Please contact dev."
        );

        uint256 amountOfTokens = allocation[msg.sender];

        claimed[msg.sender] = true;
        IERC20(TOKEN).transfer(msg.sender, amountOfTokens);
    }

    function refund() external {
        require(refundActive, "REFUND: Refunding is not active yet.");
        require(!refunded[msg.sender], "REFUND: Already refunded.");
        require(
            contributed[msg.sender] >= minAlloc,
            "REFUND: -_- invalid claim"
        );
        require(
            contributed[msg.sender] <= maxAlloc,
            "REFUND: *_* invalid claim"
        );
        require(
            IERC20(BASE).balanceOf(TREASURY) >= contributed[msg.sender],
            "REFUND: Please contact dev."
        );

        uint256 amountOfBase = contributed[msg.sender];

        refunded[msg.sender] = true;
        IERC20(BASE).transfer(msg.sender, amountOfBase);
    }

    function currentPrice() public view returns (uint256) {
        return presaleActive ? tokenPerBasePresale : tokenPerBase;
    }

    function remainingAlloc(address user) external view returns (uint256) {
        return maxAlloc - contributed[user];
    }

    function getInfo()
        external
        view
        returns (
            bool,
            bool,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256,
            uint256
        )
    {
        return (
            presaleActive,
            publicActive,
            minAlloc,
            maxAlloc,
            maxCapPresale,
            maxCapPublic,
            maxCap,
            totalSoldPresale,
            totalSoldPublic,
            totalSold,
            currentPrice()
        );
    }
}
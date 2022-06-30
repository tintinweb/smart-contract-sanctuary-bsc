pragma solidity ^0.8.10;
// SPDX-License-Identifier: MIT

import "./IPreSale1.sol";
import "./IPreSale2.sol";
import "./PreSale2.sol";

contract preSaledeployer {
    address payable public admin;
    address[] public allPreSales;

    modifier onlyAdmin() {
        require(msg.sender == admin, "!Admin");
        _;
    }

    constructor() {
        admin = payable(0xBCC722e4b46966E8D403fEc82d1f7Cd51ef6Be90);
    }

    function createPreSale1(
        address _busd,
        address _usdt,
        uint256 _price
    ) external returns (address preSaleContract) {
        bytes memory bytecode = type(PresaleAllocationBased).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(admin, allPreSales.length));

        assembly {
            preSaleContract := create2(
                0,
                add(bytecode, 32),
                mload(bytecode),
                salt
            )
        }

        allPreSales.push(preSaleContract);

        IPreSale1(preSaleContract).initialize(admin, _busd, _usdt, _price);
    }

    function createPreSale2(
        address _busd,
        address _usdt,
        uint256 _price,
        uint256 _hardCap
    ) external returns (address preSaleContract) {
        bytes memory bytecode = type(PresaleOpenAllocation).creationCode;
        bytes32 salt = keccak256(abi.encodePacked(admin, allPreSales.length));

        assembly {
            preSaleContract := create2(
                0,
                add(bytecode, 32),
                mload(bytecode),
                salt
            )
        }

        allPreSales.push(preSaleContract);

        IPreSale2(preSaleContract).initialize(
            admin,
            _busd,
            _usdt,
            _price,
            _hardCap
        );
    }

    function setAdmin(address payable _admin) external {
        admin = _admin;
    }

    function getLength() public view returns (uint256) {
        return allPreSales.length;
    }
}

pragma solidity ^0.8.10;

// SPDX-License-Identifier: MIT

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

pragma solidity ^0.8.10;

// SPDX-License-Identifier:MIT

import "./PreSale1.sol";

contract PresaleOpenAllocation {
    using SafeMath for uint256;
    IBEP20 public busd;
    IBEP20 public usdt;
    address payable public owner;
    address public deployer;

    struct User {
        uint256 amountTokens;
        bool isInvested;
        uint256 amountInvested;
    }

    bool public saleStop;
    uint256 public tokenPrice;
    uint256 public hardCap;
    uint256 public totalTokensPurchased;
    uint256 public totalBusdInvested;
    uint256 public totalUsdtInvested;
    uint256 public totalInvested;

    mapping(address => User) public users;

    constructor() {
        deployer = msg.sender;
    }

    function initialize(
        address payable _owner,
        address _busd,
        address _usdt,
        uint256 _tokenPrice,
        uint256 _hardCap
    ) public {
        require(msg.sender == deployer, "!deployer");
        owner = _owner;
        busd = IBEP20(_busd);
        usdt = IBEP20(_usdt);
        tokenPrice = _tokenPrice;
        hardCap = _hardCap;
    }

    modifier isSaleStop() {
        require(!saleStop, "Private sale is not started yet");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "access denied");
        _;
    }

    function presaleWithBusd(uint256 amountBusd, uint256 tokens)
        public
        isSaleStop
        returns (bool)
    {
        require(amountBusd >= getPrice(tokens), "less amount");
        require(
            hardCap >= tokens.add(totalTokensPurchased),
            "hard cap reached"
        );
        users[msg.sender].amountTokens = users[msg.sender].amountTokens.add(
            tokens
        );
        users[msg.sender].amountInvested = users[msg.sender].amountInvested.add(
            amountBusd
        );
        users[msg.sender].isInvested = true;
        totalTokensPurchased += tokens;
        totalBusdInvested += amountBusd;
        totalInvested += amountBusd;
        busd.transferFrom(msg.sender, address(this), amountBusd);
        return true;
    }

    function presaleWithUsdt(uint256 amountUsdt, uint256 tokens)
        public
        isSaleStop
        returns (bool)
    {
        require(amountUsdt >= getPrice(tokens), "less amount");
        require(
            hardCap >= tokens.add(totalTokensPurchased),
            "hard cap reached"
        );
        users[msg.sender].amountTokens = users[msg.sender].amountTokens.add(
            tokens
        );
        users[msg.sender].amountInvested = users[msg.sender].amountInvested.add(
            amountUsdt
        );
        users[msg.sender].isInvested = true;
        totalTokensPurchased += tokens;
        totalUsdtInvested += amountUsdt;
        totalInvested += amountUsdt;
        usdt.transferFrom(msg.sender, address(this), amountUsdt);
        return true;
    }

    function setPrice(uint256 value) public onlyOwner {
        tokenPrice = value;
    }

    function statics(address Addr)
        public
        view
        returns (
            uint256,
            bool,
            uint256
        )
    {
        return (
            users[Addr].amountTokens,
            users[Addr].isInvested,
            users[Addr].amountInvested
        );
    }

    function getPrice(uint256 tokens) public view returns (uint256) {
        return (tokens).mul(1e18).div(tokenPrice);
    }

    function setHardCap(uint256 value) public onlyOwner returns (bool) {
        hardCap = value;
        return true;
    }

    function getBusdFunds() public onlyOwner returns (bool) {
        busd.transfer(owner, busd.balanceOf(address(this)));
        return true;
    }

    function getUsdtFunds() public onlyOwner returns (bool) {
        usdt.transfer(owner, usdt.balanceOf(address(this)));
        return true;
    }

    function getBusdFundsWithValue(uint256 value)
        public
        onlyOwner
        returns (bool)
    {
        busd.transfer(owner, value);
        return true;
    }

    function getUsdtFundsWithValue(uint256 value)
        public
        onlyOwner
        returns (bool)
    {
        usdt.transfer(owner, value);
        return true;
    }

    function stopSale(bool value) public onlyOwner returns (bool) {
        saleStop = value;
        return true;
    }
}

pragma solidity ^0.8.10;

// SPDX-License-Identifier:MIT

import "./SafeMath.sol";
import "./IBEP20.sol";

contract PresaleAllocationBased {
    using SafeMath for uint256;
    IBEP20 public busd;
    IBEP20 public usdt;
    address payable public owner;
    address public deployer;

    struct User {
        uint256 amountTokens;
        bool isInvested;
        uint256 amountInvested;
    }

    bool public saleStop;
    uint256 public tokenPrice;
    uint256 public totalTokensPurchased;
    uint256 public totalBusdInvested;
    uint256 public totalUsdtInvested;

    mapping(address => User) public users;

    constructor() {
        deployer = msg.sender;
    }

    function initialize(
        address payable _owner,
        address _busd,
        address _usdt,
        uint256 _tokenPrice
    ) public {
        require(msg.sender == deployer, "!deployer");
        owner = _owner;
        busd = IBEP20(_busd);
        usdt = IBEP20(_usdt);
        tokenPrice = _tokenPrice;
    }

    modifier isSaleStop() {
        require(!saleStop, "Private sale is not started yet");
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "access denied");
        _;
    }

    function presaleWithBusd(uint256 amountBusd, uint256 tokens)
        public
        isSaleStop
        returns (bool)
    {
        require(amountBusd >= getPrice(tokens), "less amount");
        users[msg.sender].amountTokens = users[msg.sender].amountTokens.add(
            tokens
        );
        users[msg.sender].amountInvested = users[msg.sender].amountInvested.add(
            amountBusd
        );
        users[msg.sender].isInvested = true;
        totalTokensPurchased += tokens;
        totalBusdInvested += amountBusd;
        busd.transferFrom(msg.sender, address(this), amountBusd);
        return true;
    }

    function presaleWithUsdt(uint256 amountUsdt, uint256 tokens)
        public
        isSaleStop
        returns (bool)
    {
        require(amountUsdt >= getPrice(tokens), "less amount");
        users[msg.sender].amountTokens = users[msg.sender].amountTokens.add(
            tokens
        );
        users[msg.sender].amountInvested = users[msg.sender].amountInvested.add(
            amountUsdt
        );
        users[msg.sender].isInvested = true;
        totalTokensPurchased += tokens;
        totalUsdtInvested += amountUsdt;
        usdt.transferFrom(msg.sender, address(this), amountUsdt);
        return true;
    }

    function setPrice(uint256 value) public onlyOwner {
        tokenPrice = value;
    }

    function statics(address Addr)
        public
        view
        returns (
            uint256,
            bool,
            uint256
        )
    {
        return (
            users[Addr].amountTokens,
            users[Addr].isInvested,
            users[Addr].amountInvested
        );
    }

    function getPrice(uint256 tokens) public view returns (uint256) {
        return (tokens).mul(1e18).div(tokenPrice);
    }

    function getBusdFunds() public onlyOwner returns (bool) {
        busd.transfer(owner, busd.balanceOf(address(this)));
        return true;
    }

    function getUsdtFunds() public onlyOwner returns (bool) {
        usdt.transfer(owner, usdt.balanceOf(address(this)));
        return true;
    }

    function getBusdFundsWithValue(uint256 value)
        public
        onlyOwner
        returns (bool)
    {
        busd.transfer(owner, value);
        return true;
    }

    function getUsdtFundsWithValue(uint256 value)
        public
        onlyOwner
        returns (bool)
    {
        usdt.transfer(owner, value);
        return true;
    }

    function stopSale(bool value) public onlyOwner returns (bool) {
        saleStop = value;
        return true;
    }
}

pragma solidity ^0.8.10;

// SPDX-License-Identifier: MIT

interface IPreSale2 {
    function initialize(
        address payable _owner,
        address _busd,
        address _usdt,
        uint256 _tokenPrice,
        uint256 _hardcap
    ) external;
}

pragma solidity ^0.8.10;

// SPDX-License-Identifier: MIT

interface IPreSale1 {
    function initialize(
        address payable _owner,
        address _busd,
        address _usdt,
        uint256 _tokenPrice
    ) external;
}

pragma solidity ^0.8.10;

// SPDX-License-Identifier: MIT

interface IBEP20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
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
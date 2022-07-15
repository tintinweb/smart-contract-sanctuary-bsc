// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;
import "./utils/Ownable.sol";

contract Susu is Ownable {
    uint256 public totalSupply;
    uint256 public Max_Token;
    uint8 public decimals;
    string public name;
    string public symbol;
    bool mintAllowed = true;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    // Event
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    // Addresses
    address public constant technical =
        0xca1aF0a952BED5F1914cbB9ddf6cbD7a1FB371aF; // Will receive 200 M
    address public constant marketing =
        0x1c21501A554cbFB766f38Ab12C52abD78B8FA010; // Will receive 100 M
    address public constant managementInvestorsAdvisors =
        0x9C5cd556a35D722D9960Cb3c5e45C9B40fE01A7C; // Will receive 700 M
    // address public constant liquidity =
    //     0xb9acAc22f2A18Fb8e7BF8c49Ad302a8758Ad75A9; //Will receive 2.5 B
    address public constant tempCrowdsale =
        0x971ca37088734aDEB6580DB5A61d753597e2346F; // Will receive 1.5 B     ********** TESTING*******
    address public constant tempCrowdfund =
        0x667b57877D7d10dCc5FDb04BbB3291d4E1144200; // Will receive 95 B

    address public constant liquidity =
        0x971ca37088734aDEB6580DB5A61d753597e2346F; //Will receive 2.5 B ********** TESTING*******

    // Constructor
    constructor(
        string memory SYMBOL,
        string memory NAME,
        uint8 DECIMALS
    ) {
        symbol = SYMBOL;
        name = NAME;
        decimals = DECIMALS;
        uint256 decimalfactor = 10**uint256(decimals);
        Max_Token = 100_000_000_000 * decimalfactor; // 100 Billion

        mint(technical, 200_000_000 * decimalfactor);
        mint(marketing, 100_000_000 * decimalfactor);
        mint(managementInvestorsAdvisors, 700_000_000 * decimalfactor);
        mint(liquidity, 2_500_000_000 * decimalfactor);
        // mint(tempCrowdsale, 1_500_000_000 * decimalfactor);
        // mint(tempCrowdfund, 95_000_000_000 * decimalfactor);
    }

    // Internal function transfers tokens
    function _transfer(
        address _from,
        address _to,
        uint256 _value
    ) internal {
        require(_to != address(0), "to address cannot be zero");
        require(
            balanceOf[_from] >= _value,
            "from address doesn't have enough balance"
        );
        require(balanceOf[_to] + _value >= balanceOf[_to], "Addition error");

        uint256 previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;

        emit Transfer(_from, _to, _value);

        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    // Function transfers tokens from user's account to other
    function transfer(address _to, uint256 _value) public returns (bool) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    // Function transfers tokens with allowance
    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender], "Allowance error");

        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }

    // Function approves user to use tokens of msg.sender
    function approve(address _spender, uint256 _value)
        public
        returns (bool success)
    {
        allowance[msg.sender][_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    // Function burn tokens of the user    token0 = await new SampleToken__factory(owner).deploy("Token0", "Token0", 8)

    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value, "Balance is low");

        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;
        mintAllowed = true;

        emit Transfer(msg.sender, address(0), _value);
        return true;
    }

    // Function mints new tokens to the address
    function mint(address _to, uint256 _value)
        public
        onlyOwner
        returns (bool success)
    {
        require(Max_Token >= (totalSupply + _value), "Max token limit reached");

        require(mintAllowed, "Max supply reached");

        // If max tokens limit is reached, mint should not be allowed
        if (Max_Token == (totalSupply + _value)) {
            mintAllowed = false;
        }

        balanceOf[_to] += _value;
        totalSupply += _value;

        require(balanceOf[_to] >= _value, "Receiver's balance should increase");

        emit Transfer(address(0), _to, _value);

        return true;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.5;

abstract contract Ownable {
    address public owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev The Ownable constructor sets the original `owner` of the contract to the sender
     * account.
     */
    constructor() {
        _setOwner(msg.sender);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(msg.sender == owner, "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Allows the current owner to transfer control of the contract to a newOwner.
     * @param newOwner The address to transfer ownership to.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    function _setOwner(address newOwner) internal {
        owner = newOwner;
    }
}
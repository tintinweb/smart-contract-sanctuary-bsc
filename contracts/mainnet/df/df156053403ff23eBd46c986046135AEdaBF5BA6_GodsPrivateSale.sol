/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

//SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.7;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {
    
    int256 constant private INT256_MIN = -2**255;

    /**
    * @dev Multiplies two unsigned integers, reverts on overflow.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Multiplies two signed integers, reverts on overflow.
    */
    function mul(int256 a, int256 b) internal pure returns (int256) {
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
        if (a == 0) {
            return 0;
        }

        require(!(a == -1 && b == INT256_MIN)); // This is the only case of overflow not detected by the check below

        int256 c = a * b;
        require(c / a == b);

        return c;
    }

    /**
    * @dev Integer division of two unsigned integers truncating the quotient, reverts on division by zero.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity only automatically asserts when dividing by 0
        require(b > 0);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
    * @dev Integer division of two signed integers truncating the quotient, reverts on division by zero.
    */
    function div(int256 a, int256 b) internal pure returns (int256) {
        require(b != 0); // Solidity only automatically asserts when dividing by 0
        require(!(b == -1 && a == INT256_MIN)); // This is the only case of overflow

        int256 c = a / b;

        return c;
    }

    /**
    * @dev Subtracts two unsigned integers, reverts on overflow (i.e. if subtrahend is greater than minuend).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;

        return c;
    }

    /**
    * @dev Subtracts two signed integers, reverts on overflow.
    */
    function sub(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a - b;
        require((b >= 0 && c <= a) || (b < 0 && c > a));

        return c;
    }

    /**
    * @dev Adds two unsigned integers, reverts on overflow.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);

        return c;
    }

    /**
    * @dev Adds two signed integers, reverts on overflow.
    */
    function add(int256 a, int256 b) internal pure returns (int256) {
        int256 c = a + b;
        require((b >= 0 && c >= a) || (b < 0 && c < a));

        return c;
    }

    /**
    * @dev Divides two unsigned integers and returns the remainder (unsigned integer modulo),
    * reverts when dividing by zero.
    */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0);
        return a % b;
    }
}

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address who) external view returns (uint256);
    function allowance(address _owner, address spender) external view returns (uint256);
    function transfer(address to, uint256 value) external returns (bool);
    function approve(address spender, uint256 value) external returns (bool);
    function transferFrom(address from, address to, uint256 value) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract GodsPrivateSale {
    using SafeMath for uint256;

    address public owner;
    address public wallet;
    bool public enabled;
    uint256 public godsPerBnb;
    uint256 public minPurchase;
    uint256 public totalRaised;
    uint256 public fundingTarget;
    bool public useWhitelist;

    mapping(address => bool) whitelisted;
    mapping(address => uint256) public purchases;
    address[] public purchasers;
    
    modifier onlyOwner() {
        require(msg.sender == owner, "no permissions");
        _;
    }
       
    modifier isEnabled() {
        require(enabled, "sale not enabled");
        _;
    }
    
    constructor() {
        owner = 0x545933b8FA2C6603c2f79D8Ef835671Dda2f68ec;
        wallet = 0x545933b8FA2C6603c2f79D8Ef835671Dda2f68ec;

        godsPerBnb = 1000;
        minPurchase = 1000;
        fundingTarget = 370 * 10 ** 18;
        useWhitelist = true;

        whitelisted[0x9Df1fc23ad63170E1BA7c6CB18BC80c8E968EcF3] = true;
        whitelisted[0xC5710dBa415150794F4fFE12804b6F75fdA93650] = true;
        whitelisted[0xfdb11fCcf68a4C4A25535037F4b562E22068222c] = true;
        whitelisted[0xdBEd728D1Ec169f6EbB0ba0f5B60Df3Df6174B0e] = true;
        whitelisted[0xB205fB92Fc27870EA54c3A28c9Bb0B546dC3A0Ea] = true;
        whitelisted[0x19a6d28FE9942Ab02E674a4CbD11BA49562366DD] = true;
        whitelisted[0x6E56aC1A6BbFe0aF404c52413E6e60e8038Cb205] = true;
        whitelisted[0x49CA4C3c705A7eB4300d13F879fA9318A31472CC] = true;
        whitelisted[0x4cAc6D35000153599F8dE2bb582500a254E257dc] = true;
        whitelisted[0x94D4386c1414651c6EfB113264C74bD80a78772D] = true;
        whitelisted[0x47Dc1Cf9873311Dd57487b6b3d66E2EBbaF60AF6] = true;
        whitelisted[0x4a42568eeA633C5Ffe2dee1598d36Ec988919c77] = true;
        whitelisted[0x6a1bd424bC4DD47b32908bC3794822c0700fbAD8] = true;
        whitelisted[0x5E74e69DE22856aF9d0cb3227dED4eE1e90450A9] = true;
        whitelisted[0xE6dCA8c43Ec62aD03D91c88fBDE54a8E8C4a4d6c] = true;
        whitelisted[0xfef9A3194212edeb9B124aCA678d535f20E0BB03] = true;
        whitelisted[0x2a5Ac02BCb01A44C661129625355EF91D608A29b] = true;
        whitelisted[0xb3900EC3D0920534975c0e3Fd79c7553d53AceF5] = true;
        whitelisted[0xAc51AD4F5A3339533e43142733E0EF141a8BD5ee] = true;
        whitelisted[0x37d81a9133D1c444D23AE6061009F974a3b6E3fF] = true;
        whitelisted[0x2a5Ac02BCb01A44C661129625355EF91D608A29b] = true;
        whitelisted[0xF0607e43F7Fb2C888324dEAb09E34e4aBfEE6483] = true;
        whitelisted[0xafa0e0eE846a506b9891De7dF22156dC564F28ba] = true;
        whitelisted[0xE2c71805d95c210B0637e7cA87982Cb2eda17082] = true;
        whitelisted[0xdD3478f118bdf7D4E43023Ae6C087Aeb57442087] = true;
        whitelisted[0x077f09126C55C5952a27aD217f37416445B6D553] = true;
        whitelisted[0x68D5187bCd92263D239FE842a731702674C78884] = true;
        whitelisted[0xA70CE2c22250b532e0313d17DCdcE04772ff506F] = true;
        whitelisted[0x08e5DA0CE32E84dA9002953A576B08331fc02d32] = true;
        whitelisted[0xB4A13D378Be61436b3de46641162ad9770dB54Ae] = true;
        whitelisted[0xB35F5791477Adeda54823E93Ac8E89F38Bf8803A] = true;
        whitelisted[0x618BAe7B13903715d996ECFC0a0a2EA1bc707026] = true;
        whitelisted[0x34859bAFeF3eC06eB56Ac6Cf560DD2bFE814fb11] = true;
        whitelisted[0x6326751Db1d0EdDFC658f8e7e99994fFdaE1AA80] = true;
        whitelisted[0xb79a7a65df0806126843740115D12ea514050076] = true;
        whitelisted[0x610C198C34E2A945D0ee1A9A675578c653C93950] = true;
        whitelisted[0x0a9cEB535B7D04E7Fc360703D2Db3190cF4E4B8D] = true;
        whitelisted[0x9b857d0F3EA1e8318Fa863c416D368F0b289BeA8] = true;
        whitelisted[0x4b39f89C8a1De69f2f183720bc56f3EB96Df159E] = true;
        whitelisted[0x077f09126C55C5952a27aD217f37416445B6D553] = true;
        whitelisted[0xe5e2245a88a867e584EF2286595810dFD3A71900] = true;
        whitelisted[0xD1719Bf3fdc070211B0A412e0d9d1d3E35Dbdf59] = true;
        whitelisted[0x3Abf69b4F79e0da8A419FCf4DcEF4f5E10A4eE51] = true;
        whitelisted[0x98ac5E230a0EEA65F845DDeDe11ec8c08732769D] = true;
        whitelisted[0x80138154D7228A88998a97c98ad4A8d578782137] = true;
        whitelisted[0x7AC2f8f80a1cE2dEfb2CcA9Df72501F015a482C7] = true;
        whitelisted[0xd7eF9693d0634Bc2e784b6a26F5E1Ff8642bFa10] = true;
        whitelisted[0x9F04184faA711058230CB35556A622C21d487cE3] = true;
        whitelisted[0x8a56D0772dd347f34e4CABa23D1d1040c838b5ec] = true;
        whitelisted[0x6ac887288DC4a2eE80c9e678Bf114A20b7763c7d] = true;
        whitelisted[0x86C0f13B30ba3ad75aa8a9414bA5b1C1A081946C] = true;
        whitelisted[0x3cbB4074B5Fa47eEe2Cf1896F4BD5286cAc12C54] = true;
        whitelisted[0x0eBDC0E90914371cEaca368a69FEB3Ef63c61754] = true;
        whitelisted[0xa3a488646F93ABD2533Bc06b8f57298e096CE159] = true;
    }
    
    function userStatus() public view returns (
            bool saleEnabled,
            uint256 godsPrice,
            uint256 raised,
            uint256 target
        ) {
        saleEnabled = enabled && (useWhitelist == false || whitelisted[msg.sender]);
        godsPrice = godsPerBnb;
        raised = totalRaised;
        target = fundingTarget;
    }
    
    function exchange() payable public isEnabled {
        require(useWhitelist == false || whitelisted[msg.sender], "You are not whitelisted");
        uint256 receivedGods = msg.value.mul(godsPerBnb).div(100);
        require(msg.value >= minPurchase, "minimum spend not met");
        totalRaised = totalRaised.add(msg.value);
        payable(wallet).transfer(msg.value);

        if (purchases[msg.sender] == 0) {
            purchasers.push(msg.sender);
        }
        purchases[msg.sender] += receivedGods;
    }
   
    // Admin methods
    function changeOwner(address who) external onlyOwner {
        require(who != address(0), "cannot be zero address");
        owner = who;
    }
    
    function changeWallet(address who) external onlyOwner {
        require(who != address(0), "cannot be zero address");
        wallet = who;
    }

    function enableSale(bool enable) external onlyOwner {
        enabled = enable;
    }

    function setWhitelistEnabled(bool enable) external onlyOwner {
        useWhitelist = enable;
    }

    function setWhitelisted(address who, bool enable) external onlyOwner {
        whitelisted[who] = enable;
    }

    function setGodsPerBnb(uint256 gpb) external onlyOwner {
        godsPerBnb = gpb;
    }

    function setAllWhitelisted(address[] memory who, bool enable) external onlyOwner {
        for (uint256 i = 0; i < who.length; i++) {
            whitelisted[who[i]] = enable;
        }
    }

    function removeBnb() external onlyOwner {
        uint256 balance = address(this).balance;
        payable(owner).transfer(balance);
    }
    
    function transferTokens(address token, address to) external onlyOwner returns(bool){
        uint256 balance = IERC20(token).balanceOf(address(this));
        return IERC20(token).transfer(to, balance);
    }
    
   function editMinPurchase(uint256 min) external onlyOwner {
        minPurchase = min;
    }

    function editTarget(uint256 target) external onlyOwner {
        fundingTarget = target;
    }

    function airDrop(address tokenAddress) external onlyOwner {   
        IERC20 godsToken = IERC20(tokenAddress);
        for (uint256 i = 0; i < purchasers.length; i++) {
            godsToken.transfer(purchasers[i], purchases[purchasers[i]]);
        }
    }
}
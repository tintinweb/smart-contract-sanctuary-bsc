/**
 *Submitted for verification at BscScan.com on 2022-04-14
*/

// SPDX-License-Identifier: MIT
pragma solidity 0.8.9;

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

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
    * @dev Initializes the contract setting the deployer as the initial owner.
    */
    constructor () {
      address msgSender = _msgSender();
      _owner = msgSender;
      emit OwnershipTransferred(address(0), msgSender);
    }

    /**
    * @dev Returns the address of the current owner.
    */
    function owner() public view returns (address) {
      return _owner;
    }

    
    modifier onlyOwner() {
      require(_owner == _msgSender(), "Ownable: caller is not the owner");
      _;
    }

    function renounceOwnership() public onlyOwner {
      emit OwnershipTransferred(_owner, address(0));
      _owner = address(0);
    }

    function transferOwnership(address newOwner) public onlyOwner {
      _transferOwnership(newOwner);
    }

    function _transferOwnership(address newOwner) internal {
      require(newOwner != address(0), "Ownable: new owner is the zero address");
      emit OwnershipTransferred(_owner, newOwner);
      _owner = newOwner;
    }
}

interface IERC20 {
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

library SafeERC20 {
    using SafeMath for uint256;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transfer.selector, to, value)
        );
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.transferFrom.selector, from, to, value)
        );
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        callOptionalReturn(
            token,
            abi.encodeWithSelector(token.approve.selector, spender, value)
        );
    }

    function callOptionalReturn(IERC20 token, bytes memory data) private {
        require(isContract(address(token)), "SafeERC20: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = address(token).call(data);
        require(success, "SafeERC20: low-level call failed");

        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(
                abi.decode(returndata, (bool)),
                "SafeERC20: ERC20 operation did not succeed"
            );
        }
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(addr)
        }
        return size > 0;
    }
}

contract TripLandTOKEN is Context, Ownable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    address private tokenAddr = 0x78867BbEeF44f2326bF8DDd1941a4439382EF2A7; // BUSD Testnet
    IERC20 public token;

    uint256 private SHROOMS_TO_HATCH_1MINERS = 1080000;//for final version should be seconds in a day
    uint256 private PSN = 10000;
    uint256 private PSNH = 5000;
    uint256 private devFeeVal = 3;
    bool private initialized = false;
    address payable private recAdd;
    mapping (address => uint256) private shroomMiners;
    mapping (address => uint256) private claimedShrooms;
    mapping (address => uint256) private lastHatch;
    mapping (address => address) private referrals;
    uint256 private marketShrooms;
    
    constructor() {
        recAdd = payable(msg.sender);
        token = IERC20(tokenAddr);
    }
    
    function hatchShrooms(address ref) public {
        require(initialized);
        
        if(ref == msg.sender) {
            ref = address(0);
        }
        
        if(referrals[msg.sender] == address(0) && referrals[msg.sender] != msg.sender) {
            referrals[msg.sender] = ref;
        }
        
        uint256 shroomsUsed = getMyShrooms(msg.sender);
        uint256 newMiners = SafeMath.div(shroomsUsed,SHROOMS_TO_HATCH_1MINERS);
        shroomMiners[msg.sender] = SafeMath.add(shroomMiners[msg.sender],newMiners);
        claimedShrooms[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        
        //send referral shrooms
        claimedShrooms[referrals[msg.sender]] = SafeMath.add(claimedShrooms[referrals[msg.sender]],SafeMath.div(shroomsUsed,8));
        
        //boost market to nerf miners hoarding
        marketShrooms=SafeMath.add(marketShrooms,SafeMath.div(shroomsUsed,5));
    }
    
    function sellShrooms() public {
        require(initialized);
        uint256 hasShrooms = getMyShrooms(msg.sender);
        uint256 shroomValue = calculateShroomSell(hasShrooms);
        uint256 fee = devFee(shroomValue);
        claimedShrooms[msg.sender] = 0;
        lastHatch[msg.sender] = block.timestamp;
        marketShrooms = SafeMath.add(marketShrooms,hasShrooms);
        token.safeTransfer(recAdd, fee);
        token.safeTransfer(msg.sender, SafeMath.sub(shroomValue,fee));
    }
    
    function shroomRewards(address adr) public view returns(uint256) {
        uint256 hasShrooms = getMyShrooms(adr);
        uint256 shroomValue = calculateShroomSell(hasShrooms);
        return shroomValue;
    }
    
    function buyShrooms(address ref, uint256 amount) public {
        require(initialized);
        require(amount <= token.allowance(msg.sender, address(this)), "No approved tokens");
        token.safeTransferFrom(msg.sender, address(this), amount);

        uint256 shroomsBought = calculateShroomBuy(amount,SafeMath.sub(token.balanceOf(address(this)),amount));
        shroomsBought = SafeMath.sub(shroomsBought,devFee(shroomsBought));
        uint256 fee = devFee(amount);
        token.safeTransfer(recAdd, fee);
        claimedShrooms[msg.sender] = SafeMath.add(claimedShrooms[msg.sender],shroomsBought);
        hatchShrooms(ref);
    }
    
    function calculateTrade(uint256 rt,uint256 rs, uint256 bs) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(PSN,bs),SafeMath.add(PSNH,SafeMath.div(SafeMath.add(SafeMath.mul(PSN,rs),SafeMath.mul(PSNH,rt)),rt)));
    }
    
    function calculateShroomSell(uint256 shrooms) public view returns(uint256) {
        return calculateTrade(shrooms,marketShrooms,token.balanceOf(address(this)));
    }
    
    function calculateShroomBuy(uint256 eth,uint256 contractBalance) public view returns(uint256) {
        return calculateTrade(eth,contractBalance,marketShrooms);
    }
    
    function calculateShroomBuySimple(uint256 eth) public view returns(uint256) {
        return calculateShroomBuy(eth,token.balanceOf(address(this)));
    }
    
    function devFee(uint256 amount) private view returns(uint256) {
        return SafeMath.div(SafeMath.mul(amount,devFeeVal),100);
    }
    
    function seedMarket() public payable onlyOwner {
        require(marketShrooms == 0);
        initialized = true;
        marketShrooms = 108000000000;
    }
    
    function getBalance() public view returns(uint256) {
        return token.balanceOf(address(this));
    }
    
    function getMyMiners(address adr) public view returns(uint256) {
        return shroomMiners[adr];
    }
    
    function getMyShrooms(address adr) public view returns(uint256) {
        return SafeMath.add(claimedShrooms[adr],getShroomsSinceLastHatch(adr));
    }
    
    function getShroomsSinceLastHatch(address adr) public view returns(uint256) {
        uint256 secondsPassed=min(SHROOMS_TO_HATCH_1MINERS,SafeMath.sub(block.timestamp,lastHatch[adr]));
        return SafeMath.mul(secondsPassed,shroomMiners[adr]);
    }
    
    function min(uint256 a, uint256 b) private pure returns (uint256) {
        return a < b ? a : b;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a, "SafeMath: subtraction overflow");
        uint256 c = a - b;

        return c;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0, "SafeMath: division by zero");
        uint256 c = a / b;

        return c;
    }
}
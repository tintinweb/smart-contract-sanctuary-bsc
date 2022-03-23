/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

// SPDX-License-Identifier: AGPL-3.0-or-later
pragma solidity 0.7.5;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
    }

    function sub32(uint32 a, uint32 b) internal pure returns (uint32) {
        return sub32(a, b, "SafeMath: subtraction overflow");
    }

    function sub32(uint32 a, uint32 b, string memory errorMessage) internal pure returns (uint32) {
        require(b <= a, errorMessage);
        uint32 c = a - b;
        return c;
    }

    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b <= a, errorMessage);
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
        return div(a, b, "SafeMath: division by zero");
    }

    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    function sqrrt(uint256 a) internal pure returns (uint c) {
        if (a > 3) {
            c = a;
            uint b = add( div( a, 2), 1 );
            while (b < c) {
                c = b;
                b = div( add( div( a, b ), b), 2 );
            }
        } else if (a != 0) {
            c = 1;
        }
    }
}

library Address {

    function isContract(address account) internal view returns (bool) {

        uint256 size;
        // solhint-disable-next-line no-inline-assembly
        assembly { size := extcodesize(account) }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{ value: amount }("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
      return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    function functionCallWithValue(address target, bytes memory data, uint256 value, string memory errorMessage) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: value }(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _functionCallWithValue(address target, bytes memory data, uint256 weiValue, string memory errorMessage) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{ value: weiValue }(data);
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                // solhint-disable-next-line no-inline-assembly
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    function functionStaticCall(address target, bytes memory data, string memory errorMessage) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.staticcall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(address target, bytes memory data, string memory errorMessage) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.delegatecall(data);
        return _verifyCallResult(success, returndata, errorMessage);
    }

    function _verifyCallResult(bool success, bytes memory returndata, string memory errorMessage) private pure returns(bytes memory) {
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }

    function addressToString(address _address) internal pure returns(string memory) {
        bytes32 _bytes = bytes32(uint256(_address));
        bytes memory HEX = "0123456789abcdef";
        bytes memory _addr = new bytes(42);

        _addr[0] = '0';
        _addr[1] = 'x';

        for(uint256 i = 0; i < 20; i++) {
            _addr[2+i*2] = HEX[uint8(_bytes[i + 12] >> 4)];
            _addr[3+i*2] = HEX[uint8(_bytes[i + 12] & 0x0f)];
        }

        return string(_addr);

    }
}

interface IERC20 {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);
}

library SafeERC20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(IERC20 token, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(IERC20 token, address from, address to, uint256 value) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(IERC20 token, address spender, uint256 value) internal {

        require((value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(IERC20 token, address spender, uint256 value) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(value, "SafeERC20: decreased allowance below zero");
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) { // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface IOwnable {
  function owner() external view returns (address);

  function renounceManagement() external;

  function pushManagement( address newOwner_ ) external;

  function pullManagement() external;
}

contract Ownable is IOwnable {

    address internal _owner;
    address internal _newOwner;

    event OwnershipPushed(address indexed previousOwner, address indexed newOwner);
    event OwnershipPulled(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
        emit OwnershipPushed( address(0), _owner );
    }

    function owner() public view override returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require( _owner == msg.sender, "Ownable: caller is not the owner" );
        _;
    }

    function renounceManagement() public virtual override onlyOwner() {
        emit OwnershipPushed( _owner, address(0) );
        _owner = address(0);
        _newOwner = address(0);
    }

    function pushManagement( address newOwner_ ) public virtual override onlyOwner() {
        require( newOwner_ != address(0), "Ownable: new owner is the zero address");
        emit OwnershipPushed( _owner, newOwner_ );
        _newOwner = newOwner_;
    }

    function pullManagement() public virtual override {
        require( msg.sender == _newOwner, "Ownable: must be new owner to pull");
        emit OwnershipPulled( _owner, _newOwner );
        _owner = _newOwner;
        _newOwner = address(0);
    }
}

interface ITreasury {
    function allocateRewards( address _recipient, uint _amountTotal, uint _amountMint ) external;
}

interface IERC20Burnable {
    function burn(uint256 amount) external;
}

contract BoundlessJumpstarter is Ownable {

    modifier onlyPublicSale() {
        require( boundlessPublicIDO == msg.sender, "Caller is not the public sale" );
        _;
    }

    struct VestingProgram {
        uint256 lastInteraction;
        uint256 remainingPeriod;
        uint256 remainingAmount;
    }

    using SafeMath for uint256;
    using SafeMath for uint32;
    using SafeERC20 for IERC20;

    address public BND;
    address public preBOUND;
    address public boundlessPublicIDO;
    address public backingTreasury;

    mapping(address => VestingProgram) public vestingPrograms;

    uint256 public totalPreSalesAllocation = 34398 * 10**9; // sold during WL sale and seed sale
    uint256 public totalLPOfferingAllocation = 60 * 10**3 * 10**9; // max tokens for LP
    uint256 public totalPublicOfferingAllocation = 180 * 10**3 * 10**9; // max tokens for public IDO
    uint256 public totalPartnershipsAllocation = 18775 * 10**9; // max tokens for partnerships and marketing
    uint256 public totalRecycleBondingAllocation = 6827 * 10**9; // min tokens for bonding proceeds (to avoid minting new BNDs)

    uint256 public totalVestingCommitments;

    bool public jumpstarted;
    bool public initialized;

    constructor(
        address _preBOUND,
        address _boundlessPublicIDO
    ) {
        preBOUND = _preBOUND;
        boundlessPublicIDO = _boundlessPublicIDO;
    }

    function withdrawBND(uint256 _amount) external onlyOwner {
        IERC20(BND).safeTransfer(msg.sender, _amount);
        require(IERC20(BND).balanceOf(address(this)) >= totalVestingCommitments, "Vesting commitments");
    }

    function initializeSystem() external onlyOwner {
        require(!initialized, "Initialized already");
        uint256 totalMint = totalPreSalesAllocation + totalLPOfferingAllocation + totalPublicOfferingAllocation + totalPartnershipsAllocation + totalRecycleBondingAllocation;
        ITreasury(backingTreasury).allocateRewards(address(this), totalMint, totalMint);
        initialized = true;
    }

    function setAllocation(uint256 _id, uint256 _allocation) external onlyOwner {
        require(!jumpstarted, "System is jumpstarted already");
        if (_id == 1) {
          totalLPOfferingAllocation = _allocation;
        }
        else if (_id == 2) {
          totalPublicOfferingAllocation = _allocation;
        }
        else if (_id == 3) {
          totalPartnershipsAllocation = _allocation;
        }
        else if (_id == 4) {
          totalRecycleBondingAllocation = _allocation;
        }
    }

    function setContract(uint256 _id, address _address) external onlyOwner {
        require(!jumpstarted, "System is jumpstarted already");
        if (_id == 1) {
          backingTreasury = _address;
        }
        else if (_id == 2) {
          BND = _address;
        }
    }

    function assignVestingProgram(address _address, uint256 _vestingStart, uint256 _vestingPeriod, uint256 _amount) external onlyOwner {
        require(vestingPrograms[_address].remainingAmount == 0, "Vesting program already in place");
        require(IERC20(BND).balanceOf(address(this)) >= (totalVestingCommitments + _amount), "Not enough funds");
        vestingPrograms[_address] = VestingProgram({
          lastInteraction: _vestingStart,
          remainingPeriod: _vestingPeriod,
          remainingAmount: _amount
        });
        totalVestingCommitments = totalVestingCommitments + _amount;
    }

    function claim() public {
        uint256 senderPreBoundBalance = IERC20(preBOUND).balanceOf(msg.sender);
        if (senderPreBoundBalance > 0) {
          IERC20(preBOUND).safeTransferFrom(msg.sender, address(this), senderPreBoundBalance);
          IERC20(BND).safeTransfer(msg.sender, senderPreBoundBalance);
        }
    }

    function claimVestedTokens() public {
        VestingProgram memory info = vestingPrograms[msg.sender];
        require(info.remainingAmount > 0, "No vesting program");
        require(info.lastInteraction <= block.timestamp, "Vesting has not started yet");

        uint256 vestingPassed = block.timestamp - info.lastInteraction;
        uint256 vestedAmount = info.remainingAmount;

        if (vestingPassed >= info.remainingPeriod) {
          delete vestingPrograms[ msg.sender ];
        }
        else {
          vestedAmount = info.remainingAmount.mul(vestingPassed).div(info.remainingPeriod);
          vestingPrograms[msg.sender] = VestingProgram({
            lastInteraction: block.timestamp,
            remainingPeriod: info.remainingPeriod.sub(vestingPassed),
            remainingAmount: info.remainingAmount.sub(vestedAmount)
          });
        }

        IERC20(BND).safeTransfer(msg.sender, vestedAmount);
        totalVestingCommitments = totalVestingCommitments.sub(vestedAmount);
    }

    function jumpstart(uint256 _boundLiquidityNative, uint256 _boundSoldNative) external onlyPublicSale {
        require(!jumpstarted, "Jumpstarted already");
        require(_boundLiquidityNative < totalLPOfferingAllocation, "Exceeds max LP allocation");
        require(_boundSoldNative < totalPublicOfferingAllocation, "Exceeds max public sale allocation");

        uint256 boundLiquidityBurn = totalLPOfferingAllocation.sub(_boundLiquidityNative);
        uint256 boundPublicOfferingRemaining = totalPublicOfferingAllocation.sub(_boundSoldNative);
        if (boundLiquidityBurn > 0) IERC20Burnable(BND).burn(boundLiquidityBurn);
        totalRecycleBondingAllocation = totalRecycleBondingAllocation + boundPublicOfferingRemaining;

        IERC20(BND).transfer(boundlessPublicIDO, _boundLiquidityNative);
        IERC20(BND).transfer(backingTreasury, totalRecycleBondingAllocation);

        jumpstarted = true;
    }

}
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "./interfaces/IAlpacaWorker.sol";
import "./interfaces/IAlpacaVault.sol";
import "./interfaces/IShareToken.sol";
import "./interfaces/IFairLaunch.sol";
import "./access/Operatable.sol";
import "./interfaces/IWorkerConfig.sol";

contract VaultRouter is Ownable, ReentrancyGuard
{
    
    using SafeMath for uint256;
    mapping(address=>bool) public RegisteredUsers;
    mapping(uint256=>address) public Workers;
    mapping(uint256=>address) public ShareTokens;
    mapping(uint256=>address) public WorkerConfigs;
    address public Fairlaunch;
    uint256 public CashSafeThreshold;
    address public TreasuryAccount;

    event TokenAddressUpdated(address indexed previousTokenAddress, address indexed newTokenAddress, uint256 indexed workerId);
    event WorkerAddressUpdated(address indexed previousWorkerAddress, address indexed newWorkerAddress, uint256 indexed workerId);
    event UsdAddressUpdated(address indexed previousUsdAddress, address indexed newUsdAddress);
    modifier onlyFairlaunchOrOwner() 
    {
        require(Fairlaunch == _msgSender() || owner() == _msgSender(),
         "Ownable: caller is not the fairlaunch or owner");
        _;
    }
    modifier onlyRegisteredUsers()
    {
        require(RegisteredUsers[_msgSender()], "VaultRouter: caller is not a registered user");
        _;
    }
    function Deposit(uint256 amount, uint256 workerId) public onlyRegisteredUsers nonReentrant
    {
        _mintFee(workerId);
        UpdateShareVal(workerId);
        IShareToken shareToken = IShareToken(ShareTokens[workerId]);
        uint256 shares = shareToken.AmountToShare(amount);
        if(Fairlaunch != address(0)){
            IFairLaunch(Fairlaunch).WorkerDeposit(shares, workerId, _msgSender());
        }
        address baseToken = IAlpacaWorker(Workers[workerId]).BaseToken();
        TransferHelper.safeTransferFrom(baseToken, _msgSender(), Workers[workerId], amount);
        shareToken.mint(_msgSender(),shares);
        if(Fairlaunch != address(0))
        {
            IFairLaunch(Fairlaunch).UpdateWorkerInfo(amount, workerId, true);
        }
        
    }
    function Deposit_Test(uint256 amount, uint256 workerId, uint256 time, uint256 blockNo) public onlyRegisteredUsers nonReentrant
    {
        _mintFee_Test(workerId,time);
        IShareToken shareToken = IShareToken(ShareTokens[workerId]);
        UpdateShareVal(workerId);
        uint256 shares = shareToken.AmountToShare(amount);
        if(Fairlaunch != address(0)){
            IFairLaunch(Fairlaunch).WorkerDeposit_Test(shares, workerId, _msgSender(),time, blockNo);
        }
        address baseToken = IAlpacaWorker(Workers[workerId]).BaseToken();
        TransferHelper.safeTransferFrom(baseToken, _msgSender(), Workers[workerId], amount);
        shareToken.mint(_msgSender(),shares);
        if(Fairlaunch != address(0))
        {
            IFairLaunch(Fairlaunch).UpdateWorkerInfo(amount, workerId, true);
        }
        
    }
    function WithDraw(uint256 share, uint256 workerId) public onlyRegisteredUsers nonReentrant
    {
        _mintFee(workerId);
        UpdateShareVal(workerId);
        IShareToken shareToken = IShareToken(ShareTokens[workerId]);
        if(Fairlaunch != address(0))
        {
            IFairLaunch(Fairlaunch).WorkerWithdraw(share, workerId, _msgSender());
        }
        address workerAddress = Workers[workerId];
        address baseToken = IAlpacaWorker(workerAddress).BaseToken();
        uint256 amount = shareToken.ShareToAmount(share);
        require(IShareToken(baseToken).balanceOf(workerAddress) >= amount, "VaultRouter: WithDraw failed. Insufficient cash.");
        require(shareToken.balanceOf(_msgSender()) >= share,
            "VaultRouter: WithDraw failed. Insufficient share.");
        shareToken.burn(_msgSender(), share);
        Operatable(workerAddress).emergencyWithdraw(baseToken, _msgSender(), amount);
        if(Fairlaunch != address(0))
        {
            IFairLaunch(Fairlaunch).UpdateWorkerInfo(amount, workerId, false);
        }
    }
    function WithDraw_Test(uint256 share, uint256 workerId, uint256 time, uint256 blockNo) public onlyRegisteredUsers nonReentrant
    {
        _mintFee_Test(workerId,time);
        UpdateShareVal(workerId);
        IShareToken shareToken = IShareToken(ShareTokens[workerId]);
        if(Fairlaunch != address(0))
        {
            IFairLaunch(Fairlaunch).WorkerWithdraw_Test(share, workerId, _msgSender(),time, blockNo);
        }
        address workerAddress = Workers[workerId];
        address baseToken = IAlpacaWorker(workerAddress).BaseToken();
        uint256 amount = shareToken.ShareToAmount(share);
        require(IShareToken(baseToken).balanceOf(workerAddress) >= amount, "VaultRouter: WithDraw failed. Insufficient cash.");
        require(shareToken.balanceOf(_msgSender()) >= share,
            "VaultRouter: WithDraw failed. Insufficient share.");
        shareToken.burn(_msgSender(), share);
        Operatable(workerAddress).emergencyWithdraw(baseToken, _msgSender(), amount);
        if(Fairlaunch != address(0))
        {
            IFairLaunch(Fairlaunch).UpdateWorkerInfo(amount, workerId, false);
        }
    }
    function ForcedWithdraw(uint256 share, uint256 workerId) public onlyRegisteredUsers nonReentrant
    {
        _mintFee(workerId);
        UpdateShareVal(workerId);
        IShareToken shareToken = IShareToken(ShareTokens[workerId]);
        address workerAddress = Workers[workerId];
        require(shareToken.balanceOf(_msgSender()) >= share,
            "VaultRouter: WithDraw failed. Insufficient share.");
        IAlpacaWorker(workerAddress).ForcedClose(shareToken.ShareToAmount(share).mul(CashSafeThreshold).div(1000));
        UpdateShareVal(workerId);
        if(Fairlaunch != address(0))
        {
            IFairLaunch(Fairlaunch).WorkerWithdraw(share, workerId, _msgSender());
        }
        uint256 amount = shareToken.ShareToAmount(share);
        shareToken.burn(_msgSender(), share);
        address baseToken = IAlpacaWorker(workerAddress).BaseToken();
        require(IShareToken(baseToken).balanceOf(workerAddress) >= amount, "VaultRouter: WithDraw failed. Insufficient cash.");
        Operatable(workerAddress).emergencyWithdraw(baseToken, _msgSender(), amount);
        if(Fairlaunch != address(0))
        {
            IFairLaunch(Fairlaunch).UpdateWorkerInfo(amount, workerId, false);
        }
    }
    
    function EmergencyWithdrawToken(address token, address to, uint256 amount, uint256 workerId) public onlyOwner
    {
        address workerAddress = Workers[workerId];
        Operatable(workerAddress).emergencyWithdraw(token, to,  amount);
        UpdateShareVal(workerId);
    }
     function SetasideBaseToken(uint256 amount, uint256 workerId) public onlyFairlaunchOrOwner
    {
        IAlpacaWorker worker = IAlpacaWorker(Workers[workerId]);
        address token = worker.BaseToken();
        worker.ForcedClose(amount.mul(CashSafeThreshold).div(1000));
        Operatable(Workers[workerId]).emergencyWithdraw(token, Fairlaunch,  amount);
        UpdateShareVal(workerId);
    }
    function UpdateShareVal(uint256 workerId) public {
        address workerAddress = Workers[workerId];
        address shareTokenAddress = ShareTokens[workerId];
        uint256 totalUsd = IAlpacaWorker(workerAddress).TotalVal();
        IShareToken token = IShareToken(shareTokenAddress);
        uint256 totalShare = token.totalSupply();
        if(totalShare > 1e17){
          token.UpdateShareVal(totalUsd.mul(10 ** token.decimals()).div(totalShare));
        }
        else{
          token.UpdateShareVal(10 ** token.decimals());
        }

    }
    function SetParams(address fairLaunch, address treasuryAccount) public onlyOwner {
        require(fairLaunch != address(0), "Operatorable: new fairlaunch is the zero address");
        Fairlaunch = fairLaunch;
        TreasuryAccount = treasuryAccount;
    }
    
    function SetShareTokenAddress(address newTokenAddress, uint256 workerId) public onlyOwner {
        require(newTokenAddress != address(0), "Operatorable: new tokenAddress is the zero address");
        _updateTokenAddress(newTokenAddress, workerId);
    }
    function SetWorkerAddress(address newWorkerAddress, uint256 workerId) public onlyOwner {
        require(newWorkerAddress != address(0), "Operatorable: new workerAddress is the zero address");
        _updateWorkerAddress(newWorkerAddress, workerId);
    }
    function SetRegisteredUsers(address user, bool isRegistered) public onlyOwner
    {
        RegisteredUsers[user] = isRegistered;
    }
    function SetCashSafeThreshold(uint256 _threshold) public onlyOwner{
        CashSafeThreshold = _threshold;
    }
    function UpdateWorkerOperator(address newOperator, uint256 workerId) public onlyOwner{
        Operatable(Workers[workerId]).updateOperator(newOperator);
    }
    function SetWorkerManager(address newManager, uint256 workerId) public onlyOwner{
        IAlpacaWorker(Workers[workerId]).SetManagerAddress(newManager);
    }
    function TransferWorkerOwnership(address newOwner, uint256 workerId) public onlyOwner{
        require(newOwner != address(0), "VaultRouter: new owner is address zero." );
        Operatable(Workers[workerId]).transferOwnership(newOwner);
    }
    function TransferTokenOwnership(address newOwner, uint256 workerId) public onlyOwner{
        require(newOwner != address(0), "VaultRouter: new owner is address zero." );
        Operatable(ShareTokens[workerId]).transferOwnership(newOwner);
    }
     /**
     * @dev Update tokenAddress of the contract
     * Internal function without access restriction.
     */
    function _updateTokenAddress(address newTokenAddress, uint256 workerId) internal{
        address previousTokenAddress = ShareTokens[workerId];
        ShareTokens[workerId] = newTokenAddress;
        emit TokenAddressUpdated(previousTokenAddress, ShareTokens[workerId], workerId);
    }

    /**
     * @dev Update WorkerAddress of the contract
     * Internal function without access restriction.
     */
    function _updateWorkerAddress(address newWorkerAddress, uint256 workerId) internal{

        address previousWorkerAddress = Workers[workerId];
        Workers[workerId] = newWorkerAddress;
        emit TokenAddressUpdated(previousWorkerAddress, Workers[workerId], workerId);
    }
    function _mintFee(uint256 workerId) internal {

        IWorkerConfig config = IWorkerConfig(WorkerConfigs[workerId]);
        IShareToken(ShareTokens[workerId]).mint(TreasuryAccount, config.PendingManagementFee());
        config.SetLastFeeCollected(block.timestamp);
    }
    function _mintFee_Test(uint256 workerId, uint256 time) internal {

        IWorkerConfig config = IWorkerConfig(WorkerConfigs[workerId]);
        IShareToken(ShareTokens[workerId]).mint(TreasuryAccount, config.PendingManagementFee_Test(time));
        config.SetLastFeeCollected(time);
    }
    

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (security/ReentrancyGuard.sol)

pragma solidity ^0.8.0;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant _NOT_ENTERED = 1;
    uint256 private constant _ENTERED = 2;

    uint256 private _status;

    constructor() {
        _status = _NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        // On the first call to nonReentrant, _notEntered will be true
        require(_status != _ENTERED, "ReentrancyGuard: reentrant call");

        // Any calls to nonReentrant after this point will fail
        _status = _ENTERED;

        _;

        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = _NOT_ENTERED;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeApprove: approve failed'
        );
    }

    function safeTransfer(
        address token,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::safeTransfer: transfer failed'
        );
    }

    function safeTransferFrom(
        address token,
        address from,
        address to,
        uint256 value
    ) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(
            success && (data.length == 0 || abi.decode(data, (bool))),
            'TransferHelper::transferFrom: transferFrom failed'
        );
    }

    function safeTransferETH(address to, uint256 value) internal {
        (bool success, ) = to.call{value: value}(new bytes(0));
        require(success, 'TransferHelper::safeTransferETH: ETH transfer failed');
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the substraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IAlpacaWorker
{

    function ApproveToken(address token, address to, uint256 value) external;
    function ClosePosition(uint256 id, uint slippage) external returns (uint256);
    function ForcedClose(uint256 amount) external;
    function TotalVal() external view returns(uint256);
    function SetManagerAddress(address newManager) external;
    function BaseToken() external view returns(address);
    function ShareToken() external view returns(address);
    function manager() external view returns(address);
    function WithdrawToken(address token, address to,  uint256 value) external;
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IAlpacaVault {
  struct Position {
        address worker;
        address owner;
        uint256 debtShare;
    }    
  function nextPositionID() external view returns (uint256);
  /// @dev Return the total ERC20 entitled to the token holders. Be careful of unaccrued interests.
  function totalToken() external view returns (uint256);
  function totalSupply()external view returns (uint256);
  /// @dev Add more ERC20 to the bank. Hope to get some good returns.
  function deposit(uint256 amountToken) external payable;

  /// @dev Withdraw ERC20 from the bank by burning the share tokens.
  function withdraw(uint256 share) external;
  
  function token() external view returns (address);
  
  function work(uint256 id, address worker, uint256 principalAmount, uint256 borrowAmount, uint256 maxReturn, bytes calldata data) external payable;
  function positions(uint256 id) external view returns (Position memory);
  function debtShareToVal(uint256 share) external view returns (uint256);
  function balanceOf(address user) external view returns (uint256);
  function config() external view returns (address);
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IShareToken {
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `recipient`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address recipient, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `sender` to `recipient` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

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
  function mint(address account, uint256 amount) external;
  function burn(address account, uint256 amount) external;
  function UpdateShareVal(uint val) external;
  function ShareToAmount(uint256 share) external view returns (uint256);
  function AmountToShare(uint256 amount) external view returns (uint256);
  function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
/**
  ∩~~~~∩ 
  ξ ･×･ ξ 
  ξ　~　ξ 
  ξ　　 ξ 
  ξ　　 “~～~～〇 
  ξ　　　　　　 ξ 
  ξ ξ ξ~～~ξ ξ ξ 
　 ξ_ξξ_ξ　ξ_ξξ_ξ
Alpaca Fin Corporation
*/

pragma solidity ^0.8.0;

interface IFairLaunch {
  
  function UpdateWorker(uint256 workerId) external;
  function UpdateWorkerInfo(uint256 amount, uint workerId, bool isDeposit) external;
  function WorkerDeposit(uint256 amount, uint256 workerId, address from) external;
  function WorkerWithdraw(uint256 amount, uint256 workerId, address to) external;
  function WorkerDeposit_Test(uint256 amount, uint256 workerId, address from,uint256 time, uint256 blockNo) external;
  function WorkerWithdraw_Test(uint256 amount, uint256 workerId, address to,uint256 time, uint256 blockNo) external;
  
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
import "@openzeppelin/contracts/access/Ownable.sol";

contract Operatable is Ownable {
    address private Operator;
    
    event OperatorUpdated(address indexed previousOperator, address indexed newOperator);
    function operator() public view returns(address) 
    {
        return Operator;
    }
    modifier onlyOperator() 
    {
        require(operator() == _msgSender(), "Ownable: caller is not the operator");
        _;
    }
    function updateOperator(address newOperator) public onlyOwner 
    {
        require(newOperator != address(0), "Ownable: new operator is the zero address");
        _updateOperator(newOperator);
    }

    function emergencyWithdraw(address token, address to,  uint256 value) public onlyOwner 
    {
        TransferHelper.safeTransfer(token, to , value);
    }
    /**
     * @dev Update operator of the contract
     * Internal function without access restriction.
     */
    function _updateOperator(address newOperator) internal {
        address previousOperator = Operator;
        Operator = newOperator;
        emit OperatorUpdated(previousOperator, Operator);
    }
    
    
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


interface IWorkerConfig
{
    struct WokerBase{
        address Worker;
        address ShareToken;
        address Config;

    }
    function ManagerDiscount() external view returns(int256[2] memory);
    function Add(int256 rate, int256 time)  external;
    function PendingManagementFee() external view returns(uint256);
    function PendingManagementFee_Test(uint256 time) external view returns(uint256);
    function SetLastFeeCollected(uint256 time) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/Ownable.sol)

pragma solidity ^0.8.0;

import "../utils/Context.sol";

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
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

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
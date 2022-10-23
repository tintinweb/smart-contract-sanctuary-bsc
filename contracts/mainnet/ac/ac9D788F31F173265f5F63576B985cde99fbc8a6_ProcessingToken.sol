/**
 *Submitted for verification at BscScan.com on 2022-10-23
*/

pragma solidity 0.8.13;
// SPDX-License-Identifier: MIT

interface IERC20 {
    function totalSupply() external view returns (uint256);
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function getOwner() external view returns (address);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address _owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function getHolder(uint256 _index) external view returns (address);
    function getHolders() external view returns (uint256);
    function getDividendTokens() external view returns (uint256);
    function isDisabledDividends(address account) external view returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

library Address {

    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize, which returns 0 for contracts in
        // construction, since the code is only stored at the end of the
        // constructor execution.

        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }


    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }


    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }


    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

interface PancakeSwapFactoryV2 {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface PancakeSwapRouterV2 {
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint256 amountIn,
        uint256 amountOutMin,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external;
    function factory() external pure returns (address);
    function getAmountsIn(uint256 amountOut, address[] calldata path) external view returns (uint256[] memory amounts);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function WETH() external pure returns (address);
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function addLiquidityETH(
        address token,
        uint amountTokenDesired,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function swapETHForExactTokens(uint256 amountOut, address[] calldata path, address to, uint deadline)
        external
        payable
        returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
        external
        returns (uint[] memory amounts);
    function swapExactTokensForTokens(uint256 amountIn, uint256 amountOutMin, address[] calldata path, address to, uint256 deadline) 
        external 
        returns (uint256[] memory amounts);
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }
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

abstract contract Ownable {
    address private _owner;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor () {
        _owner = msg.sender;
    }
    
    function owner() public view virtual returns (address) {
        return _owner;
    }
    
    modifier onlyOwner() {
        require(owner() == msg.sender, "Ownable: caller is not the owner");
        _;
    }
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract ProcessingToken is Ownable {
    using SafeERC20 for IERC20;
    using SafeMath for uint256;

    struct ClaimedByUserStructure {
        uint256 ClaimedTokens;
        uint256 LotteryWinTokens;
        uint256 balance;
        uint256 lastClaimingPoints;
    }
    struct ClaimStructure {
        address TokenAddress;
        uint256 allTokensTurnover;
        uint256 allTokensUnClaimed;
        uint256 allTokensClaimed;
        uint256 ClaimablePoints;
    }

    struct lotHistoryStructure {
        uint256 timestamp;
        address TokenAddress;
        address winner;
        uint256 WinSum;
    }

    struct lotteryStructure {
        uint256 startLotteryTimestamp;
        address tokenAddress;
        uint256 lotteryInterval;
        uint256 PoolAmount;
        uint256 countWinners;
        uint256 allWinnersSum;
    }

    mapping(address => bool) public isWhitelisted;
    mapping(address => lotteryStructure[]) LotteryList;
    mapping(uint256 => lotHistoryStructure[]) public LotteryHistoryList;
    mapping(address => mapping(address => ClaimedByUserStructure)) public claimBalanceUser;
    mapping(address => ClaimStructure[]) public ClaimableList;
    mapping(address => uint256) public lotteryIndex;
    mapping(address => uint256) public claimableIndex;
    uint256 pointMultiplier = 1000000000000000000;
    uint256 lotteryStandartInterval = 30; //86400
    IERC20 private _token = IERC20(0x0000000000000000000000000000000000000000);
    IERC20 private _busd = IERC20(0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56);

    event Claim(address indexed _claimer, address _tokenAddress, uint256 _amount);
    event LotteryDistribution(address indexed _winnerAddress, address _tokenAddress, uint256 _winnerSum);

    constructor() {
    isWhitelisted[msg.sender] = true;
    isWhitelisted[address(this)] = true;
    isWhitelisted[address(_token)] = true;
    }

// CLAIMABLE
    function getClaimableBalance(address _tokenAddress, address account) public view returns(uint256) {
        if(claimableIndex[_tokenAddress] == 0 || _token.isDisabledDividends(account)) return 0;
        uint256 newDividendPoints = ClaimableList[address(this)][claimableIndex[_tokenAddress]-1].ClaimablePoints.sub(claimBalanceUser[_tokenAddress][account].lastClaimingPoints);
        return (IERC20(_tokenAddress).balanceOf(account).mul(newDividendPoints)).div(pointMultiplier);
    }
    function _storeClaimableToken(address _tokenAddress) private returns (bool success) {
        ClaimStructure memory claimablestructure = ClaimStructure(_tokenAddress,uint256(0), uint256(0), uint256(0), uint256(0));
        ClaimableList[address(this)].push(claimablestructure);
        claimableIndex[_tokenAddress] = ClaimableList[address(this)].length;
        return true;
    }
    function storeClaimableToken(address _tokenAddress) public onlyOwner returns (bool success) {
        if(claimableIndex[_tokenAddress] == 0 ) { 
            return _storeClaimableToken(_tokenAddress); 
            } else {  
            return false; 
        }
    }
    function addToClaimable(address _tokenAddress, uint256 _amount) public returns(bool) {
        require(isWhitelisted[msg.sender], "You are not allowed for this operation");
        if(claimableIndex[_tokenAddress] == 0 ) { _storeClaimableToken(_tokenAddress); }
        ClaimableList[address(this)][claimableIndex[_tokenAddress]-1].allTokensTurnover = ClaimableList[address(this)][claimableIndex[_tokenAddress]-1].allTokensTurnover + _amount;
        ClaimableList[address(this)][claimableIndex[_tokenAddress]-1].allTokensUnClaimed = ClaimableList[address(this)][claimableIndex[_tokenAddress]-1].allTokensUnClaimed + _amount;
       if(_token.getDividendTokens() > 0) { ClaimableList[address(this)][claimableIndex[_tokenAddress]-1].ClaimablePoints = ClaimableList[address(this)][claimableIndex[_tokenAddress]-1].ClaimablePoints.add((_amount.mul(pointMultiplier)).div(_token.getDividendTokens())); }
        return true;
    }
    function _getTokenClaimableAmmountAfterSwap(address _tokenAddress) private view returns(uint256) {
        uint256 AvailableTokens = IERC20(_tokenAddress).balanceOf(address(this));
        if(lotteryIndex[_tokenAddress] > 0 ) { AvailableTokens -= LotteryList[address(this)][lotteryIndex[_tokenAddress]-1].PoolAmount; }
        if(claimableIndex[_tokenAddress] > 0 ) { AvailableTokens -= (ClaimableList[address(this)][claimableIndex[_tokenAddress]-1].allTokensTurnover - ClaimableList[address(this)][claimableIndex[_tokenAddress]-1].allTokensClaimed); }
        return AvailableTokens;
    }
    function addToClaimableAfterSwap(address _tokenAddress) public returns(bool) {
        uint256 newAmount = _getTokenClaimableAmmountAfterSwap(_tokenAddress);
        if(newAmount == 0) return false;
        addToClaimable(_tokenAddress, newAmount);
        return true;
    }
    function getClaimableDetails(uint256 _index) external view returns(address TokenAddress, uint256 allTokensTurnover, uint256 allTokensClaimed, uint256 allTokensUnClaimed, uint256 ClaimablePoints) {
        ClaimStructure memory claimablestructure = ClaimableList[address(this)][_index];
        TokenAddress = claimablestructure.TokenAddress;
        allTokensTurnover = claimablestructure.allTokensTurnover;
        allTokensClaimed = claimablestructure.allTokensClaimed;
        allTokensUnClaimed = claimablestructure.allTokensUnClaimed;
        ClaimablePoints = claimablestructure.ClaimablePoints;
    }
    function claim(address account) public {
      for(uint256 i = 0; i < ClaimableList[address(this)].length; i++ ){
        uint256 owing = getClaimableBalance(ClaimableList[address(this)][i].TokenAddress, account);
        if(owing > 0 && IERC20(ClaimableList[address(this)][i].TokenAddress).balanceOf(address(this)) >= owing) {
         if(IERC20(ClaimableList[address(this)][i].TokenAddress).balanceOf(address(this)) < owing) { return; }
        ClaimableList[address(this)][i].allTokensUnClaimed = ClaimableList[address(this)][i].allTokensUnClaimed.sub(owing);
        ClaimableList[address(this)][i].allTokensClaimed = ClaimableList[address(this)][i].allTokensClaimed.add(owing);
        claimBalanceUser[ClaimableList[address(this)][i].TokenAddress][account].ClaimedTokens = claimBalanceUser[ClaimableList[address(this)][i].TokenAddress][account].ClaimedTokens.add(owing);
        IERC20(ClaimableList[address(this)][i].TokenAddress).safeTransfer(account, owing);
        emit Claim(account, ClaimableList[address(this)][i].TokenAddress, owing);
        }
        if(_token.isDisabledDividends(account)) {
        claimBalanceUser[ClaimableList[address(this)][i].TokenAddress][account].balance = 0;
        } else {
        claimBalanceUser[ClaimableList[address(this)][i].TokenAddress][account].balance = _token.balanceOf(account);
        }
        claimBalanceUser[ClaimableList[address(this)][i].TokenAddress][account].lastClaimingPoints =  ClaimableList[address(this)][i].ClaimablePoints;
      }
    }
// CLAIMABLE

// LOTTERY START
    function _setLotteryHistory(uint256 _lotteryId, address _tokenAddress, address _winnerAddress, uint256 _winnerSum) private returns (bool success) {
        lotHistoryStructure memory lotterystructurehistory = lotHistoryStructure(block.timestamp, _tokenAddress, _winnerAddress, _winnerSum);
        LotteryHistoryList[_lotteryId].push(lotterystructurehistory);
        emit LotteryDistribution(_winnerAddress, _tokenAddress, _winnerSum);
        return true;
    }
    function _storeLottery(address _tokenAddress, uint256 lotteryInterval) private returns (bool success) {
        require(isWhitelisted[msg.sender], "You are not allowed for this operation");
        lotteryStructure memory lotterystructure = lotteryStructure(block.timestamp, _tokenAddress, lotteryInterval, uint256(0), uint256(0), uint256(0));
        LotteryList[address(this)].push(lotterystructure);
        lotteryIndex[_tokenAddress] = LotteryList[address(this)].length;
        return true;
    }
    function storeLottery(address _tokenAddress, uint256 lotteryInterval) public onlyOwner returns (bool success) {
        if(lotteryIndex[_tokenAddress] == 0 ) { 
            return _storeLottery(_tokenAddress,lotteryInterval); 
            } else {  
            return false; 
        }
    }
    function getLotteryHistoryCount(address _tokenAddress) public view returns (uint256 _CountHistory) {
        if(lotteryIndex[_tokenAddress] == 0 ) { 
            return 0; 
            } else {  
            return LotteryHistoryList[lotteryIndex[_tokenAddress]-1].length; 
        }
    }
    function random(uint _torandomize) private view returns (uint) {
      return uint(keccak256(abi.encodePacked(block.difficulty, block.timestamp+_torandomize, _token.getHolders())));
    }
    function pickWinner(uint _torandomize) private view returns(uint) {
     uint index=random(_torandomize)%_token.getHolders();
     return index;
    }
    function getLotteryDetails(uint256 _index) external view returns(uint256 startLotteryTimestamp, address _tokenAddress, uint256 lotteryInterval, uint256 PoolAmount, uint256 countWinners, uint256 allWinnersSum) {
        lotteryStructure memory lotterystructure = LotteryList[address(this)][_index];
        startLotteryTimestamp = lotterystructure.startLotteryTimestamp;
        _tokenAddress = lotterystructure.tokenAddress;
        lotteryInterval = lotterystructure.lotteryInterval;
        PoolAmount = lotterystructure.PoolAmount;
        countWinners = lotterystructure.countWinners;
        allWinnersSum = lotterystructure.allWinnersSum;
    }
    function _getLotteryWinner(uint _torandomize) private view returns(address) {
        return _token.getHolder(pickWinner(_torandomize));
    }
    function addToLottery(address _tokenAddress, uint256 _amount) public returns(bool) {
        require(isWhitelisted[msg.sender], "You are not allowed for this operation");
        if(lotteryIndex[_tokenAddress] <= 0 ) { _storeLottery(_tokenAddress, lotteryStandartInterval); }
        LotteryList[address(this)][lotteryIndex[_tokenAddress]-1].PoolAmount = LotteryList[address(this)][lotteryIndex[_tokenAddress]-1].PoolAmount + _amount;
        if((LotteryList[address(this)][lotteryIndex[_tokenAddress]-1].startLotteryTimestamp.add(LotteryList[address(this)][lotteryIndex[_tokenAddress]-1].lotteryInterval)) <= block.timestamp) {
         _distributionLottery();
        }
        return true;
    }
    function _getTokenLotteryAmmountAfterSwap(address _tokenAddress) private view returns(uint256) {
        uint256 AvailableTokens = IERC20(_tokenAddress).balanceOf(address(this));
        if(claimableIndex[_tokenAddress] > 0 ) { AvailableTokens -= (ClaimableList[address(this)][claimableIndex[_tokenAddress]-1].allTokensTurnover - ClaimableList[address(this)][claimableIndex[_tokenAddress]-1].allTokensClaimed); }
        if(lotteryIndex[_tokenAddress] > 0 ) { AvailableTokens -= LotteryList[address(this)][lotteryIndex[_tokenAddress]-1].PoolAmount; }
        return AvailableTokens;
    }
    function addToLotteryAfterSwap(address _tokenAddress) public returns(bool) {
        require(isWhitelisted[msg.sender], "You are not allowed for this operation");
        uint256 newAmount = _getTokenLotteryAmmountAfterSwap(_tokenAddress);
        if(newAmount <= 0) return false;
        addToLottery(_tokenAddress, newAmount);
        return true;
    }
    function changeLotteryInterval(address _tokenAddress, uint256 _newInterval) public onlyOwner returns(bool) {
        if(lotteryIndex[_tokenAddress] == 0 ) return false;
        LotteryList[address(this)][lotteryIndex[_tokenAddress]-1].lotteryInterval = _newInterval;
        return true;
    }
    function _distributionLottery() private returns (bool success) {
        for(uint256 i = 0; i < LotteryList[address(this)].length; i++ ){
         if((LotteryList[address(this)][i].startLotteryTimestamp.add(LotteryList[address(this)][i].lotteryInterval)) <= block.timestamp) {
          address winnerAddress = _getLotteryWinner(i*123);
          if(winnerAddress != address(0) && winnerAddress != address(_token)) {
          uint256 winnerSum = LotteryList[address(this)][i].PoolAmount;
           if(winnerSum > 0) { 
           IERC20(LotteryList[address(this)][i].tokenAddress).safeTransfer(winnerAddress, winnerSum);
           LotteryList[address(this)][i].allWinnersSum += winnerSum;
           LotteryList[address(this)][i].PoolAmount = 0;
           LotteryList[address(this)][i].startLotteryTimestamp = block.timestamp;
           claimBalanceUser[LotteryList[address(this)][i].tokenAddress][winnerAddress].LotteryWinTokens = claimBalanceUser[LotteryList[address(this)][i].tokenAddress][winnerAddress].LotteryWinTokens.add(winnerSum);
           _setLotteryHistory(i, LotteryList[address(this)][i].tokenAddress, winnerAddress, winnerSum);
           }
          }
         }
        }
        return true;
    }
    function distributeLottery() public onlyOwner returns (bool success) {
        return _distributionLottery();
    }
// LOTTERY END

    function setBUSD(address newBusd) public onlyOwner returns (bool success) {
        _busd = IERC20(newBusd);
        return true;
    }

    function setToken(address newToken) public onlyOwner returns (bool success) {
        isWhitelisted[address(_token)] = false;
        isWhitelisted[newToken] = true;
        _token = IERC20(newToken);
        return true;
    }

    function setisWhitelisted(address account, bool value) public onlyOwner {
        isWhitelisted[account] = value;
    }
}
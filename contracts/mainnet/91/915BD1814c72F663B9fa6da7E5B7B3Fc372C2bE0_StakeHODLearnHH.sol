/**
 *Submitted for verification at BscScan.com on 2022-12-20
*/

// SPDX-License-Identifier: Unlicensed

pragma solidity 0.8.17;

library SafeMath {

    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, 'SafeMath: subtraction overflow');
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
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
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
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    function sqrt(uint256 y) internal pure returns (uint256 z) {
        if (y > 3) {
            z = y;
            uint256 x = y / 2 + 1;
            while (x < z) {
                z = x;
                x = (y / x + x) / 2;
            }
        } else if (y != 0) {
            z = 1;
        }
    }
}

interface IBEP20 {

    function totalSupply() external view returns (uint256);

    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

    function getOwner() external view returns (address);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address _owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function getRate() external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface IHODLHAND {

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);

    function balanceOf(address owner) external view returns (uint256 balance);

    function ownerOf(uint256 tokenId) external view returns (address owner);

    function walletOfOwner(address _owner) external view returns(uint256[] memory);

    function safeTransferFrom(address from, address to, uint256 tokenId) external;

    function transferFrom(address from, address to, uint256 tokenId) external;

    function approve(address to, uint256 tokenId) external;

    function getApproved(uint256 tokenId) external view returns (address operator);

    function setApprovalForAll(address operator, bool _approved) external;

    function isApprovedForAll(address owner, address operator) external view returns (bool);

    function safeTransferFrom(address from, address to, uint256 tokenId, bytes calldata data) external;

    function getPrice() external view returns (uint256);

    function purchase(uint256 num) external payable;

    function totalSupply() external view returns (uint);

}

interface IPancakeRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);

    function swapETHForExactTokens(

        uint256 amountOut,
        address[] calldata path,
        address to,
        uint256 deadline
    ) external payable returns (uint256[] memory amounts);

    function getAmountOut(
        uint256 amountIn,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountOut);

    function getAmountIn(
        uint256 amountOut,
        uint256 reserveIn,
        uint256 reserveOut
    ) external pure returns (uint256 amountIn);

    function getAmountsOut(uint256 amountIn, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);

    function getAmountsIn(uint256 amountOut, address[] calldata path)
        external
        view
        returns (uint256[] memory amounts);
}

interface IERC721Receiver {
    /**
     * @dev Whenever an {IERC721} `tokenId` token is transferred to this contract via {IERC721-safeTransferFrom}
     * by `operator` from `from`, this function is called.
     *
     * It must return its Solidity selector to confirm the token transfer.
     * If any other value is returned or the interface is not implemented by the recipient, the transfer will be reverted.
     *
     * The selector can be obtained in Solidity with `IERC721Receiver.onERC721Received.selector`.
     */
    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external returns (bytes4);
}

contract ERC721Holder is IERC721Receiver {
  function onERC721Received(
    address,
    address,
    uint256,
    bytes calldata
  )
    public
    pure
    returns(bytes4)
  {
    return this.onERC721Received.selector;
  }
}

library Address {

    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, 'Address: insufficient balance for call');
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), 'Address: call to non-contract');

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(data);
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
}

library SafeBEP20 {
    using SafeMath for uint256;
    using Address for address;

    function safeTransfer(
        IBEP20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IBEP20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    function safeApprove(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            'SafeBEP20: approve from non-zero to non-zero allowance'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).add(value);
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IBEP20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender).sub(
            value,
            'SafeBEP20: decreased allowance below zero'
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function _callOptionalReturn(IBEP20 token, bytes memory data) private {

        bytes memory returndata = address(token).functionCall(data, 'SafeBEP20: low-level call failed');
        if (returndata.length > 0) {
            // Return data is optional
            // solhint-disable-next-line max-line-length
            require(abi.decode(returndata, (bool)), 'SafeBEP20: BEP20 operation did not succeed');
        }
    }
}

contract Context {
    constructor() {}

    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }

    function _msgData() internal view returns (bytes memory) {
        this;
        return msg.data;
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), 'Ownable: caller is not the owner');
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
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

contract StakeHODLearnHH is Ownable, ERC721Holder {
    using SafeMath for uint256;
    using SafeBEP20 for IBEP20;

    // Info of each user.
    struct UserInfo {
        uint256 amount;     // How many LP tokens the user has provided.
        uint256 rewardDebt; // Reward debt. See explanation below.
        uint256 earnedReward;
        uint256 rate;
    }

    // Info of each pool.
    struct PoolInfo {
        IBEP20 lpToken;           // Address of LP token contract.
        uint256 lastRewardBlock;  // Last block number that Hands distribution occurs.
        uint256 accHandPerShare; // Accumulated Hands per share, times 1e12. See below.
    }

    // The Hand TOKEN!
    IBEP20 public token;
    IHODLHAND public hand;

    // Hand tokens created per block.
    uint256 public handPerBlock; // times le18, this is only calculation

    // Info of each pool.
    PoolInfo[] public poolInfo;
    // Info of each user that stakes LP tokens.
    mapping (address => UserInfo) public userInfo;
    // The block number when Hand mining starts.
    uint256 public startBlock;
    // The block number when Hand mining ends.
    uint256 public bonusEndBlock;

    uint256 public depositFee;

    IPancakeRouter private pancakeRouter = IPancakeRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
    address private BUSDaddress = 0xe9e7CEA3DedcA5984780Bafc599bD69ADd087D56;

    event Deposit(address indexed user, uint256 amount);
    event Withdraw(address indexed user, uint256 amount);
    event EmergencyWithdraw(address indexed user, uint256 amount);

    constructor(
        IBEP20 _token,
        IHODLHAND _hand,
        uint256 _handPerBlock,
        uint256 _startBlock,
        uint256 _bonusEndBlock,
        uint256 _depositFee
    ) {
        token = _token;
        hand = _hand;
        handPerBlock = _handPerBlock;
        startBlock = _startBlock;
        bonusEndBlock = _bonusEndBlock;
        depositFee = _depositFee*1e16;

        // staking pool
        poolInfo.push(PoolInfo({
            lpToken: _token,
            lastRewardBlock: startBlock,
            accHandPerShare: 0
        }));

    }

    function getUserInfo(address _user) public view returns(
        uint256 amount,
        uint256 rewardDebt,
        uint256 earnedReward
    ) {
        uint256 currentRate = poolInfo[0].lpToken.getRate();
        UserInfo memory user = userInfo[_user];
        return (
            user.amount * user.rate / currentRate,
            user.rewardDebt,
            user.earnedReward
        );
    }

    // Return reward multiplier over the given _from to _to block.
    function getMultiplier(uint256 _from, uint256 _to) public view returns (uint256) {
        if (_to <= bonusEndBlock) {
            return _to.sub(_from);
        } else if (_from >= bonusEndBlock) {
            return 0;
        } else {
            return bonusEndBlock.sub(_from);
        }
    }

    // View function to see pending Reward on frontend.
    function pendingReward(address _user) external view returns (uint256) {
        PoolInfo memory pool = poolInfo[0];
        UserInfo memory user = userInfo[_user];
        user.amount = user.amount * user.rate / pool.lpToken.getRate();
        uint256 accHandPerShare = pool.accHandPerShare;
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (block.number > pool.lastRewardBlock && lpSupply != 0) {
            uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
            uint256 handReward = multiplier.mul(handPerBlock);
            accHandPerShare = accHandPerShare.add(handReward.mul(1e12).div(lpSupply));
        }
        return user.amount.mul(accHandPerShare).div(1e12).add(user.earnedReward).sub(user.rewardDebt);
    }

    // Update reward variables of the given pool to be up-to-date.
    function updatePool() private {
        PoolInfo storage pool = poolInfo[0];
        if (block.number <= pool.lastRewardBlock) {
            return;
        }
        uint256 lpSupply = pool.lpToken.balanceOf(address(this));
        if (lpSupply == 0) {
            pool.lastRewardBlock = block.number;
            return;
        }
        uint256 multiplier = getMultiplier(pool.lastRewardBlock, block.number);
        uint256 handReward = multiplier.mul(handPerBlock);
        pool.accHandPerShare = pool.accHandPerShare.add(handReward.mul(1e12).div(lpSupply));
        pool.lastRewardBlock = block.number;
    }

    function updateUserReflections(UserInfo storage user) private {
        uint256 currentRate = poolInfo[0].lpToken.getRate();
        user.amount = user.amount * user.rate / currentRate;
        user.rate = currentRate;
    }

    error WrongDepositFee(uint256 required, uint256 passed);

    // Stake HODL tokens to SmartChef
    function deposit(uint256 _amount) public payable {
        require(_amount > 0, "Nothing to deposit");

        if (depositFee > 0) {
            if (msg.value < getFee()) {
                revert WrongDepositFee({
                    required: getFee(),
                    passed: msg.value
                });
            }
        }

        UserInfo storage user = userInfo[msg.sender];
        PoolInfo storage pool = poolInfo[0];
        updatePool();

        if (user.amount > 0) {
            updateUserReflections(user);
            user.earnedReward = user.amount.mul(pool.accHandPerShare).div(1e12).add(user.earnedReward).sub(user.rewardDebt);
        }

        pool.lpToken.safeTransferFrom(address(msg.sender), address(this), _amount);
        user.amount = user.amount.add(_amount);
        user.rate = pool.lpToken.getRate();
       
        user.rewardDebt = user.amount.mul(pool.accHandPerShare).div(1e12);        

        emit Deposit(msg.sender, _amount);
    }

    // Withdraw HODL tokens from STAKING.
    function withdraw(uint256 _amount) public {
        UserInfo storage user = userInfo[msg.sender];
        PoolInfo storage pool = poolInfo[0];
        updateUserReflections(user);
        require(user.amount >= _amount, "withdraw: not good");
        updatePool();
        uint256 pending = user.amount.mul(pool.accHandPerShare).div(1e12).add(user.earnedReward).sub(user.rewardDebt);
        uint256 pendingWithDecimal = pending.div(1e18);
        user.earnedReward = pending.sub(pendingWithDecimal.mul(1e18));
        if(pendingWithDecimal > 0) {
            mintHand(pendingWithDecimal);
        }
        if(_amount > 0) {
            user.amount = user.amount.sub(_amount);
            pool.lpToken.safeTransfer(address(msg.sender), _amount);
        }

        user.rewardDebt = user.amount.mul(pool.accHandPerShare).div(1e12);  // error when withdraw

        emit Withdraw(msg.sender, _amount);
    }

    // Withdraw without caring about rewards. EMERGENCY ONLY.
    function emergencyWithdraw() public {
        UserInfo storage user = userInfo[msg.sender];
        updateUserReflections(user);
        poolInfo[0].lpToken.safeTransfer(address(msg.sender), user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.earnedReward = 0;
        emit EmergencyWithdraw(msg.sender, user.amount);
    }

    //Withdraw with NFT by paying rest cost
    function emergencyWithdrawWithRestNft() public payable {
        UserInfo storage user = userInfo[msg.sender];
        updateUserReflections(user);
        updatePool();
        uint256 pending = user.amount.mul(poolInfo[0].accHandPerShare).div(1e12).add(user.earnedReward).sub(user.rewardDebt);
        uint256 pendingWithDecimal = pending.div(1e18).add(1);
        uint256 restAmountHand = pendingWithDecimal.mul(1e18).sub(pending);
        uint256 payableBnbAmount = restAmountHand.mul(hand.getPrice()).div(1e18);
        require(msg.value >= payableBnbAmount, "not enough BNB!");
        poolInfo[0].lpToken.safeTransfer(address(msg.sender), user.amount);
        user.amount = 0;
        user.rewardDebt = 0;
        user.earnedReward = 0;
        mintHand(pendingWithDecimal);
    }

    function mintHand(uint256 _amountHands) private {
        uint256 currentSupply = IHODLHAND(hand).totalSupply();
        IHODLHAND(hand).purchase{value: _amountHands * IHODLHAND(hand).getPrice()}(_amountHands);
        for(uint256 i; i < _amountHands; i++) {
            IHODLHAND(hand).transferFrom(address(this), _msgSender(), currentSupply+i);
        }
    }

    function withdrawBNB() public payable onlyOwner {
        uint256 amount = address(this).balance;
        payable(owner()).transfer(amount);
    }

    function getFee() public view returns(uint256) {
        uint256 neededBNB;
        if (depositFee > 0) {
            address[] memory path = new address[](2);
            path[0] = BUSDaddress;
            path[1] = pancakeRouter.WETH();
            neededBNB = pancakeRouter.getAmountsOut(depositFee, path)[1];
        }
        return neededBNB;
    }

    function changeDepositFee(uint256 _depositFee) external onlyOwner {
        depositFee = _depositFee*1e16;
    }

    receive() external payable {}

    //For testing
    function getRestBNB(address _user) public view returns(uint256) {
        UserInfo memory user = userInfo[_user];
        user.amount = user.amount * user.rate / poolInfo[0].lpToken.getRate();
        //updatePool();
        uint256 pending = user.amount.mul(poolInfo[0].accHandPerShare).div(1e12).add(user.earnedReward).sub(user.rewardDebt);
        uint256 pendingWithDecimal = pending.div(1e18).add(1);
        uint256 restAmountHand = pendingWithDecimal.mul(1e18).sub(pending);
        return restAmountHand.mul(hand.getPrice()).div(1e18);
    }
}
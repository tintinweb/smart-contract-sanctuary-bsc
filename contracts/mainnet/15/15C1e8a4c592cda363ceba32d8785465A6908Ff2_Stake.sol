// SPDX-License-Identifier: UNLICENSED


pragma solidity 0.6.12;

import "./BEP20.sol";

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Pair {
    event Approval(address indexed owner, address indexed spender, uint value);
    event Transfer(address indexed from, address indexed to, uint value);

    function name() external pure returns (string memory);
    function symbol() external pure returns (string memory);
    function decimals() external pure returns (uint8);
    function totalSupply() external view returns (uint);
    function balanceOf(address owner) external view returns (uint);
    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint value) external returns (bool);
    function transfer(address to, uint value) external returns (bool);
    function transferFrom(address from, address to, uint value) external returns (bool);

    function DOMAIN_SEPARATOR() external view returns (bytes32);
    function PERMIT_TYPEHASH() external pure returns (bytes32);
    function nonces(address owner) external view returns (uint);

    function permit(address owner, address spender, uint value, uint deadline, uint8 v, bytes32 r, bytes32 s) external;

    event Burn(address indexed sender, uint amount0, uint amount1, address indexed to);
    event Swap(
        address indexed sender,
        uint amount0In,
        uint amount1In,
        uint amount0Out,
        uint amount1Out,
        address indexed to
    );
    event Sync(uint112 reserve0, uint112 reserve1);

    function MINIMUM_LIQUIDITY() external pure returns (uint);
    function factory() external view returns (address);
    function token0() external view returns (address);
    function token1() external view returns (address);
    function getReserves() external view returns (uint112 reserve0, uint112 reserve1, uint32 blockTimestampLast);
    function price0CumulativeLast() external view returns (uint);
    function price1CumulativeLast() external view returns (uint);
    function kLast() external view returns (uint);

    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
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
    function removeLiquidity(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETH(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountToken, uint amountETH);
    function removeLiquidityWithPermit(
        address tokenA,
        address tokenB,
        uint liquidity,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountA, uint amountB);
    function removeLiquidityETHWithPermit(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountToken, uint amountETH);
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapTokensForExactTokens(
        uint amountOut,
        uint amountInMax,
        address[] calldata path,
        address to,
        uint deadline
    ) external returns (uint[] memory amounts);
    function swapExactETHForTokens(uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);
    function swapTokensForExactETH(uint amountOut, uint amountInMax, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapExactTokensForETH(uint amountIn, uint amountOutMin, address[] calldata path, address to, uint deadline)
    external
    returns (uint[] memory amounts);
    function swapETHForExactTokens(uint amountOut, address[] calldata path, address to, uint deadline)
    external
    payable
    returns (uint[] memory amounts);

    function quote(uint amountA, uint reserveA, uint reserveB) external pure returns (uint amountB);
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) external pure returns (uint amountOut);
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) external pure returns (uint amountIn);
    function getAmountsOut(uint amountIn, address[] calldata path) external view returns (uint[] memory amounts);
    function getAmountsIn(uint amountOut, address[] calldata path) external view returns (uint[] memory amounts);
}

interface IUniswapV2Router02 is IUniswapV2Router01 {
    function removeLiquidityETHSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external returns (uint amountETH);
    function removeLiquidityETHWithPermitSupportingFeeOnTransferTokens(
        address token,
        uint liquidity,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline,
        bool approveMax, uint8 v, bytes32 r, bytes32 s
    ) external returns (uint amountETH);

    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
    function swapExactETHForTokensSupportingFeeOnTransferTokens(
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external payable;
    function swapExactTokensForETHSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}



abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() internal {
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

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
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
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


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


contract Stake is Ownable{
    using SafeMath for uint256;

    struct PoolInfo {
        address token0;
        address token1;
        address awardToken;
        uint awardPerDay;
        uint powerSum;
        uint debtSum;
        uint accPerPower;
        uint minLimit;
        uint lastRewardTime;
    }

    mapping(uint8 => PoolInfo) public poolInfo;

    //bsc
    address public usdt = address(0);
    //rinkeby
    // address public usdt = address(0x10681E51eA76b0F66fe6a9433a4326Fd2B5c84c5);
    //bsctest
    // address public usdt = address(0x7860554d6A0c9094299c5f9A41fFB305e2283f43);

    address public destroyAddress = address(0x000000000000000000000000000000000000dEaD);

    address public cw = address(0);
    address public cwt = address(0);

    address public usdtReceiver = address(0);
    address public usdtReceiverNode = address(0);

    bool public init = false;

    uint256[] public referRewardRate = [10,5,5,5,5,4,4,4,4,4,3,3,3,3,3,3,3,3,3,3,2,2,2,2,2,2,2,2,2,2];

    struct UserInfo {
        uint power;
        uint debt;
        uint static_award;
        uint static_usdt;
        uint award;
        uint pendingAward;
        uint award_in_usdt;
    }

    struct NodeInfo {
        bool active;
        uint count;
        address referrer;
        mapping(uint => address) nodes;
    }

    mapping(address => NodeInfo) public nodeInfo;
    mapping(uint8 => mapping(address => UserInfo)) public userInfo;

    IUniswapV2Router02 public uniswapV2Router;
    IUniswapV2Factory public factory;

    address[] public users;
    mapping(address => uint256) public userIndexes;
    mapping(address => bool) public isUser;

    mapping(address => bool) public isCWT;

    event Acitve(address indexed user, address upline);
    event Award(uint8 pid, address indexed user, address upline, uint amount, uint award, uint g);
    event TakeAward(uint8 pid, address indexed user, uint amount);
    event Add(uint8 pid, address indexed user, uint amount, uint amount2, uint multiple);
    event Harvest(uint8 pid, address indexed user, uint amount, uint award);
    event Node(address indexed user, uint node, uint amount, uint amount2);

    constructor(address _usdt, address _cw, address _cwt) public {

        usdt = _usdt;
        cw = _cw;
        cwt = _cwt;

        usdtReceiver = address(0x8E33a07db809c02df3E19c66BDa3E0678db487C5);
        usdtReceiverNode = address(0xb7d1EA63eE0FBb63F9A629768D12cBfb84A7D5A2);

        nodeInfo[msg.sender].active = true;
        userIndexes[msg.sender] = users.length;
        users.push(msg.sender);
        isUser[msg.sender] = true;

        //dev
        // uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        //rinkeby
        // uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        //bsctest
        // uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        //bsc
        uniswapV2Router = IUniswapV2Router02(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        
        
        factory = IUniswapV2Factory(uniswapV2Router.factory());

        poolInfo[0].token0 = usdt;
        poolInfo[0].token1 = cw;
        poolInfo[0].awardToken = cw;
        poolInfo[0].awardPerDay = 1200 * 1e18;
        poolInfo[0].minLimit = 200 * 1e18;
    }

    // function claimFee(address token, address addr, uint amount) public onlyOwner {
    //     if(token != address(0)) {
    //         TransferHelper.safeTransfer(token, addr, amount);
    //     }else{
    //         TransferHelper.safeTransferETH(addr, amount);
    //     }
    // }

    function setUint(uint index, uint value) public onlyOwner {
        if(index == 0) {
            PoolInfo storage pool = poolInfo[0];
            pool.awardPerDay = value;
        }
    }

    function getChild(address addr, uint index) public view returns (address) {
        return nodeInfo[addr].nodes[index];
    }

    // function getPowerSum(uint8 pid) public view returns (uint) {
    //     PoolInfo storage pool = poolInfo[pid];
    //     if(pool.powerSum > pool.debtSum.div(3)) {
    //         return pool.powerSum.sub(pool.debtSum.div(3));
    //     }else{
    //         return 0;
    //     }
    // }

    /*
     * 输出多少币
     */
    function pendingAward(uint8 pid, address addr) public view returns (uint, uint) {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][addr];

        uint accPerPower_tmp = pool.accPerPower;
        if(now > pool.lastRewardTime && pool.powerSum > 0) {
            uint multiplier = now.sub(pool.lastRewardTime);
  
            accPerPower_tmp = accPerPower_tmp.add(pool.awardPerDay.mul(multiplier).mul(1e18).div(1 days).div(pool.powerSum));
        }
        // award in token
        uint award = user.power.mul(accPerPower_tmp).div(1e18).sub(user.debt);
        uint power_left = getUserPowerLeft(pid, addr);
        if(power_left == 0) {
            return (0, 0);
        }
        address[] memory path = new address[](2);
        path[0] = address(pool.awardToken);
        path[1] = address(usdt);
        //币转token数量
        uint[] memory amounts_in = uniswapV2Router.getAmountsIn(1e18, path);
        if(award > amounts_in[0].mul(power_left).div(1e18)) {
            award = amounts_in[0].mul(power_left).div(1e18);
        }
        return (award, award.mul(1e18).div(amounts_in[0]));
    }

    function getUserPowerLeft(uint8 pid, address addr) public view returns (uint) {
        UserInfo storage user = userInfo[pid][addr];
        if(user.power > user.static_usdt.add(user.award_in_usdt)) {
            return user.power.sub(user.static_usdt.add(user.award_in_usdt));
        }else{
            return 0;
        }
    }

    function updatePool(uint8 pid) public {
        PoolInfo storage pool = poolInfo[pid];

        if(pool.powerSum == 0) {
            pool.lastRewardTime = now;
            return;
        }
        uint multiplier = now.sub(pool.lastRewardTime);
        pool.accPerPower = pool.accPerPower.add(pool.awardPerDay.mul(multiplier).mul(1e18).div(1 days).div(pool.powerSum));
        pool.lastRewardTime = now;
    }

    function doActive(address addr) public returns (bool) {
        NodeInfo storage upnode = nodeInfo[addr];
        require(upnode.active, 'upnode must be actived');
        NodeInfo storage node = nodeInfo[msg.sender];
        require(node.active == false, 'have active');
        node.active = true;
        node.referrer = addr;

        upnode.nodes[upnode.count] = msg.sender;
        upnode.count += 1;

        emit Acitve(msg.sender, addr);
        return true;
    }

    function harvest(uint8 pid) public returns (bool) {
        _harvest(pid, msg.sender);
    }

    function _harvest(uint8 pid, address addr) private returns (bool) {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][addr];
        uint power_left = getUserPowerLeft(pid, addr);
        updatePool(pid);
        if(power_left == 0) {
            return true;
        }
        //award in token
        uint pending;
        uint pendingPower;
        (pending, pendingPower) = pendingAward(pid, addr);
        if(pending > 0) {
            //award in awardToken
            TransferHelper.safeTransfer(pool.awardToken, addr, pending);
            
            user.static_award += pending;
            user.static_usdt += pendingPower;
            pool.debtSum += pendingPower;
        
            emit Harvest(pid, addr, pendingPower, pending);
            user.debt = user.power.mul(pool.accPerPower).div(1e18);
        }

        return true;
    }

    function addToken2(uint8 pid, uint amount) public returns (bool) { 
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        require(amount >= pool.minLimit, 'less then min');

        updatePool(pid);
        uint power_left = getUserPowerLeft(pid, msg.sender);
        if(power_left > 0) {
            uint pending;
            uint pendingPower;
            (pending, pendingPower) = pendingAward(pid, msg.sender);
            if( pending > 0 ) {
                TransferHelper.safeTransfer(pool.awardToken, msg.sender, pending);
                user.static_award += pending;
                user.static_usdt += pendingPower;
                pool.debtSum += pendingPower;
            }
        }
        uint multiple = 3;
        uint power = amount.mul(multiple);
        require(BEP20(cwt).balanceOf(msg.sender) >= amount, 'cwt balance insufficient');
        require(BEP20(cwt).allowance(msg.sender, address(this)) >= amount, 'cwt allow insufficient');
        //收币
        TransferHelper.safeTransferFrom(cwt, msg.sender, destroyAddress, amount);

        user.power = user.power.add(power);
        user.debt = user.power.mul(pool.accPerPower).div(1e18);
        pool.powerSum = pool.powerSum.add(power);

        if(!isUser[msg.sender]) {
            userIndexes[msg.sender] = users.length;
            users.push(msg.sender);
            isUser[msg.sender] = true;
        }

        // doAward(pid, msg.sender, amount);

        emit Add(pid, msg.sender, amount, 0, multiple);
    }

    function addToken(uint8 pid, uint amount) public returns (uint256) {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        updatePool(pid);
        uint power_left = getUserPowerLeft(pid, msg.sender);
        if(power_left > 0) {
            uint pending;
            uint pendingPower;
            (pending, pendingPower) = pendingAward(pid, msg.sender);
            if( pending > 0 ) {
                TransferHelper.safeTransfer(pool.awardToken, msg.sender, pending);
                user.static_award += pending;
                user.static_usdt += pendingPower;
                pool.debtSum += pendingPower;
            }
        }
        uint multiple = 3;
        if(amount > 0) {
            require(amount >= pool.minLimit.div(2), 'less then min');
            address[] memory path = new address[](2);
            if(pool.token0 != address(0)) {
                require(BEP20(pool.token0).balanceOf(msg.sender) >= amount, 'token0 balance insufficient');
                require(BEP20(pool.token0).allowance(msg.sender, address(this)) >= amount, 'token0 allow insufficient');
                //收币
                TransferHelper.safeTransferFrom(pool.token0, msg.sender, usdtReceiver, amount);

                //token0 兑换 token1
                // path[0] = address(pool.token0);
                // path[1] = address(pool.token1);
                // BEP20(pool.token0).approve(address(uniswapV2Router), amount);
                // uniswapV2Router.swapExactTokensForTokensSupportingFeeOnTransferTokens(amount, 0, path, address(destroyAddress), now + 600);
                // uniswapV2Router.swapExactTokensForTokens(amount, 0, path, address(this), now + 600);
                user.power = user.power.add(amount.mul(multiple));
                pool.powerSum = pool.powerSum.add(amount.mul(multiple));

                if(!isUser[msg.sender]) {
                    userIndexes[msg.sender] = users.length;
                    users.push(msg.sender);
                    isUser[msg.sender] = true;
                }
            }
            uint amount2 = 0;
            if(pool.token1 != address(0)) {
                path[0] = address(pool.token1);
                path[1] = address(usdt);
                uint[] memory amounts_in = uniswapV2Router.getAmountsIn(amount, path);
                amount2 = amounts_in[0];
                require(BEP20(pool.token1).balanceOf(msg.sender) >= amount2, 'token1 balance insufficient');
                require(BEP20(pool.token1).allowance(msg.sender, address(this)) >= amount2, 'token1 allow insufficient');
                TransferHelper.safeTransferFrom(pool.token1, msg.sender, address(destroyAddress), amount2);
                user.power = user.power.add(amount.mul(multiple));
                pool.powerSum = pool.powerSum.add(amount.mul(multiple));
            }
            emit Add(pid, msg.sender, amount, amount2, multiple);

            //奖励
            doAward(pid, msg.sender, amount);
        }

        user.debt = user.power.mul(pool.accPerPower).div(1e18);
        return multiple;
    }

    function doAward(uint8 pid, address from, uint256 amount) internal {
        PoolInfo storage pool = poolInfo[pid];

        address addr = from;
        uint destroySum = 0;
        for(uint256 g=0; g<20; g++) {
            uint256 reward = amount.mul(referRewardRate[g]).div(100);
            NodeInfo storage userNode = nodeInfo[addr];
            UserInfo storage upline = userInfo[pid][userNode.referrer];
            NodeInfo storage upNode = nodeInfo[userNode.referrer];
            uint power_left = getUserPowerLeft(pid, userNode.referrer);

            address[] memory path = new address[](2);
            path[0] = address(pool.awardToken);
            path[1] = address(usdt);
            uint[] memory amounts_in = uniswapV2Router.getAmountsIn(reward, path);            

            if(userNode.referrer != address(0) && upNode.count > g && power_left >= reward) {
   
                pool.debtSum += reward;
                upline.pendingAward += amounts_in[0];
                upline.award_in_usdt += reward;

                // TransferHelper.safeTransfer(pool.awardToken, userNode.referrer, amounts_in[0]);
                emit Award(pid, from, userNode.referrer, reward, amounts_in[0], g);
            }else{
                //销毁
                destroySum += amounts_in[0];
            }
            addr = userNode.referrer;
        }
        TransferHelper.safeTransfer(pool.awardToken, destroyAddress, destroySum);
    }

    function takeAward(uint8 pid) public {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];

        require(user.pendingAward > 0, 'no pending award');

        uint pending = user.pendingAward;

        user.pendingAward = 0;
        user.award += pending;

        TransferHelper.safeTransfer(pool.awardToken, msg.sender, pending);

        emit TakeAward(pid, msg.sender, pending);
    }

    function getNode(uint node) public {
        if(node == 1) {
            TransferHelper.safeTransferFrom(usdt, msg.sender, usdtReceiverNode, 1200*1e18);
            TransferHelper.safeTransfer(cwt, msg.sender, 2000*1e18);
            emit Node(msg.sender, node, 1200*1e18, 2000*1e18);
        } else if(node == 2) {
            TransferHelper.safeTransferFrom(usdt, msg.sender, usdtReceiverNode, 600*1e18);
            TransferHelper.safeTransfer(cwt, msg.sender, 750*1e18);
            emit Node(msg.sender, node, 600*1e18, 750*1e18);
        } else if(node == 3) {
            TransferHelper.safeTransferFrom(usdt, msg.sender, usdtReceiverNode, 200*1e18);
            TransferHelper.safeTransfer(cwt, msg.sender, 220*1e18);
            emit Node(msg.sender, node, 200*1e18, 220*1e18);
        }
    }
}
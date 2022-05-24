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
        address tokenlp;
        address awardToken;
        uint awardPerDay;
        uint powerSum;
        uint debtSum;
        uint accPerPower;
        uint minLimit;
        uint lastRewardTime;
    }

    mapping(uint8 => PoolInfo) public poolInfo;

    address public destroyAddress = address(0x000000000000000000000000000000000000dEaD);


    uint256[] public referRewardRate = [10,8,5,3,2,2,2,1,1,1];
    uint256[] public angleAwardRate = [0, 10, 15, 20, 30];
    //prod
    uint256[] public angleTeam = [0, 50000 * 1e18, 100000 * 1e18, 200000 * 1e18, 500000 * 1e18];
    //dev
    // uint256[] public angleTeam = [0, 5000 * 1e18, 10000 * 1e18, 20000 * 1e18, 50000 * 1e18];

    struct UserInfo {
        uint power;
        uint teamPower;
        uint debt;
        uint static_award; //静态奖励
        uint award;        //推荐奖励
        uint pendingTeamAward;    //未领取团队奖励
        uint teamAward;           //已领取团队奖励
    }

    struct NodeInfo {
        bool active;
        uint count;
        uint directCount;
        uint teamCount;
        address referrer;
        mapping(uint => address) nodes;
    }

    mapping(address => NodeInfo) public nodeInfo;
    mapping(uint8 => mapping(address => UserInfo)) public userInfo;

    uint256 public nodeLimit = 1000 * 1e18;
    uint256 public angleLimit = 2000 * 1e18;

    //prod 
    IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x1B6C9c20693afDE803B27F8782156c0f892ABC2d);
    address public fist = address(0xC9882dEF23bc42D53895b8361D0b1EDC7570Bc6A);
    address public atm = address(0xbF8a70bc18d42e3782Ee89f72E5E3456d8327ceA);
    address public fist_atm_lp = address(0);
    
    //rinkey
    // IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
    // address fist = address(0x10681E51eA76b0F66fe6a9433a4326Fd2B5c84c5);
    // address atm = address(0x10681E51eA76b0F66fe6a9433a4326Fd2B5c84c5);

    //bsctest
    // IUniswapV2Router02 uniswapV2Router = IUniswapV2Router02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
    // address fist = address(0x487008A9578a831C44a32587Ec7fB7df6edA8eb5);
    // address atm = address(0x165154366b896Af8D6EC863d221e6208929f92E9);
    // address fist_atm_lp = address(0);

    event Acitve(address indexed user, address upline);
    event Award(uint8 pid, address indexed user, address upline, uint award, uint g);
    event Add(uint8 pid, address indexed user, uint amount);
    event Withdraw(uint8 pid, address indexed user, uint award);
    event GetTeamAward(uint8 pid, address indexed user, uint award);
    event AngleAward(uint8 pid, address indexed from, address indexed user, uint award);

    constructor() public {
        nodeInfo[msg.sender].active = true;

        fist_atm_lp = IUniswapV2Factory(uniswapV2Router.factory()).getPair(atm, fist);
        
        if( fist_atm_lp == address(0) ) {
            fist_atm_lp = IUniswapV2Factory(uniswapV2Router.factory()).createPair(atm, fist);
        }

        poolInfo[0].tokenlp = fist_atm_lp;
        poolInfo[0].awardToken = atm;
        poolInfo[0].awardPerDay = 3000 * 1e18;
        poolInfo[0].minLimit = 0 * 1e18;
    }

    // function claimFee(address token, address addr, uint amount) public onlyOwner {
    //     if(token != address(0)) {
    //         TransferHelper.safeTransfer(token, addr, amount);
    //     }else{
    //         TransferHelper.safeTransferETH(addr, amount);
    //     }
    // }

    function setPool(uint8 pid, uint _awardPerDay) public onlyOwner {
        PoolInfo storage pool = poolInfo[pid];
        pool.awardPerDay = _awardPerDay;
    }

    function setUint(uint index, uint value) public onlyOwner {
        if(index == 0) {
            nodeLimit = value;
        }else if(index == 1) {
            angleLimit = value;
        }
    }

    function getChild(address addr, uint index) public view returns (address) {
        return nodeInfo[addr].nodes[index];
    }

    function pendingAward(uint8 pid, address addr) public view returns (uint) {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][addr];

        uint accPerPower_tmp = pool.accPerPower;
        if(now > pool.lastRewardTime && pool.powerSum > 0) {
            uint multiplier = now.sub(pool.lastRewardTime);
  
            accPerPower_tmp = accPerPower_tmp.add(pool.awardPerDay.mul(multiplier).mul(1e18).div(1 days).div(pool.powerSum));
        }
        // award in token
        uint award = user.power.mul(accPerPower_tmp).div(1e18).sub(user.debt);
        return award;
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

        address addr_tmp = msg.sender;
        for(uint256 g=0; g<10; g++) {
            NodeInfo storage node_tmp = nodeInfo[addr_tmp];
            if(node_tmp.referrer != address(0)) {
                NodeInfo storage up_node = nodeInfo[node_tmp.referrer];
                up_node.teamCount += 1;
                addr_tmp = node_tmp.referrer;
            }else{
                break;
            }
        }

        emit Acitve(msg.sender, addr);
        return true;
    }

    function withdraw(uint8 pid, uint256 amount) public returns (bool) {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        NodeInfo storage node = nodeInfo[msg.sender];
        
        require(user.power >= amount, 'amount err');
        updatePool(pid);

        //award in token
        uint pending = pendingAward(pid, msg.sender);
        if(pending > 0) {
            TransferHelper.safeTransfer(pool.awardToken, msg.sender, pending);
            user.static_award += pending;
            pool.debtSum += pending;
        
            emit Withdraw(pid, msg.sender, pending);
            doAngleAward(pid, msg.sender, pending);
        }
        if(amount > 0) {
            address addr = msg.sender;
            for(uint256 g=0; g<10; g++) {
                NodeInfo storage node_tmp = nodeInfo[addr];
                if(node_tmp.referrer != address(0)) {
                    UserInfo storage upline = userInfo[pid][node_tmp.referrer];
                    upline.teamPower -= amount;
                    addr = node_tmp.referrer;
                }else{
                    break;
                }
            }

            if(user.power >= nodeLimit && user.power - amount < nodeLimit && nodeInfo[node.referrer].directCount > 0 ) {
                nodeInfo[node.referrer].directCount -= 1;
            }

            user.power = user.power.sub(amount);
            pool.powerSum = pool.powerSum.sub(amount);

            //退lp
            TransferHelper.safeTransfer(pool.tokenlp, msg.sender, amount);
        }
        user.debt = user.power.mul(pool.accPerPower).div(1e18);
        return true;
    }

    function addToken(uint8 pid, uint amount) public returns (uint256) {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        NodeInfo storage node = nodeInfo[msg.sender];

        updatePool(pid);

        uint pending = pendingAward(pid, msg.sender);
        
        if( pending > 0 ) {
            TransferHelper.safeTransfer(pool.awardToken, msg.sender, pending);
            user.static_award += pending;
            pool.debtSum += pending;
            doAngleAward(pid, msg.sender, pending);
        }
    
        if(amount > 0) {
            require(amount >= pool.minLimit, 'less then min');
            require(BEP20(pool.tokenlp).balanceOf(msg.sender) >= amount, 'tokenlp balance insufficient');
            //收币
            TransferHelper.safeTransferFrom(pool.tokenlp, msg.sender, address(this), amount);

            if(user.power < nodeLimit && user.power + amount >= nodeLimit ) {
                nodeInfo[node.referrer].directCount += 1;
            }

            user.power = user.power.add(amount);
            pool.powerSum = pool.powerSum.add(amount);


            emit Add(pid, msg.sender, amount);

            //奖励
            doAward(pid, msg.sender, amount);
        }


        user.debt = user.power.mul(pool.accPerPower).div(1e18);
        return 0;
    }

    function doAward(uint8 pid, address from, uint256 amount) internal {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage userFrom = userInfo[pid][from];
        address addr = from;
        
        for(uint256 g=0; g<10; g++) {
            uint256 reward = amount.mul(referRewardRate[g]).div(100);
            NodeInfo storage userNode = nodeInfo[addr];
            UserInfo storage upline = userInfo[pid][userNode.referrer];
            upline.teamPower += amount;

            NodeInfo storage upNode = nodeInfo[userNode.referrer];
          
            if(userNode.referrer != address(0) && upNode.directCount > g && upline.power >= nodeLimit ) {
   
                pool.debtSum += reward;
                upline.award += reward;

                TransferHelper.safeTransfer(pool.awardToken, userNode.referrer, reward);
                emit Award(pid, from, userNode.referrer, reward, g);
            }
            addr = userNode.referrer;
        }
    }

    function getTeamLevel(uint8 pid, address addr) view public returns (uint) {
        UserInfo storage user = userInfo[pid][addr];
        if(user.teamPower >= angleTeam[4]) {
            return 4;
        }else if(user.teamPower >= angleTeam[3]) {
            return 3;
        }else if(user.teamPower >= angleTeam[2]) {
            return 2;
        }else if(user.teamPower >= angleTeam[1]) {
            return 1;
        }else {
            return 0;
        }
    }

    function doAngleAward(uint8 pid, address from, uint256 amount) internal {
        PoolInfo storage pool = poolInfo[pid];

        address addr = from;

        uint256 reward_send = 0;

        for(uint256 g=0; g < 10; g++) {
            UserInfo storage user = userInfo[pid][addr];
            NodeInfo storage node = nodeInfo[addr];
            UserInfo storage upline = userInfo[pid][node.referrer];
            if(node.referrer != address(0) && upline.power >= angleLimit) {
                uint level = getTeamLevel(pid, node.referrer);
                uint award_tmp = amount.mul(angleAwardRate[level]).div(100);

                if(award_tmp > reward_send) {
                    uint award = award_tmp.sub(reward_send);
                    pool.debtSum += award;
                    upline.pendingTeamAward += award;
                    TransferHelper.safeTransfer(pool.awardToken, node.referrer, award);
                    emit AngleAward(pid, from, node.referrer, award);
                }
                reward_send = award_tmp;
            }
            addr = node.referrer;
        }
    }

    function getTeamAward(uint8 pid) public {
        PoolInfo storage pool = poolInfo[pid];
        UserInfo storage user = userInfo[pid][msg.sender];
        uint award = user.pendingTeamAward;
        require(award > 0, 'no award');
        TransferHelper.safeTransfer(pool.awardToken, msg.sender, award);
        user.pendingTeamAward = 0;
        user.teamAward += award;
        emit GetTeamAward(pid, msg.sender, award);
    }
}
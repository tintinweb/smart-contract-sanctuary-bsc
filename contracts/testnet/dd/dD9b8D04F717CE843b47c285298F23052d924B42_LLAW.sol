// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

import "../pancakeswap_interface/IPancakeRouter.sol";

import "../pancakeswap_interface/IPancakeFactory.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IStakePool {
    function updateReward(uint256 burnAmount) external returns (bool);
}

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
contract LLAW is Ownable {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 amount
    );
    event UpdateReward(uint256 updateAmount, uint256 updateTime);
    string public name;
    
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 internal immutable INITIAL_CHAIN_ID;
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;
    mapping(address => uint256) public nonces;
    address public DEAD_ADDRESS = 0x000000000000000000000000000000000000dEaD;
    //交易对地址
    address public pairAddress;
    //pancakeRouter
    // IPancakeRouter02 private pancakeRouter;
    //pancakeFactory
    // IPancakeFactory private pancakeFactory;
    //StakingPool address
    address public stakingPoolAddress;

    //白名单地址
    address private whitelistAddress;
    //流动性添加地址
    address private liquidityAddress;
    //技术
    address private devAddress;
    //运营
    address private operatorAddress;
    //空投锁仓合约地址
    address private airdropLockAddress;
    //超级节点分红合约
    address private superNodeAddress;
    //主节点分红合约
    address private mainNodeAddress;
    //财富节点分红合约
    address private richNodeAddress;
    //手续费白名单
    mapping(address => bool) public feeWhitelist;
    //邀请关系映射
    mapping(address => address) public inviter; //user=> inviter
    //记录第一次添加流动性时池子中两种币的存量
    // uint256 public firstToken0;
    // uint256 public firstToken1;
    // //记录销毁数量
    uint256 public destroyAmount;
    //开始时间
    uint256 public startTime;
    //日销毁量
    uint256 public dayDestroyAmount;
    //累计总销毁量
    uint256 public totalDestroyAmount;

    constructor(
        address _stakingPoolAddress,
        address _whitelistAddress,
        address _liquidityAddress,
        address _devAddress,
        address _operatorAddress,
        address _airdropLockAddress,
        address _superNodeAddress,
        address _mainNodeAddress,
        address _richNodeAddress
    ) {
        name = "LLAW DAO TOKEN";
        symbol = "LLAW";
        decimals = 18;

        //矿池合约地址
        _mint(_stakingPoolAddress, 2000_0000 ether);
        //白名单
        _mint(_whitelistAddress, 20_0000 ether);
        //流动性添加地址
        _mint(_liquidityAddress, 20_0000 ether);
        //技术
        _mint(_devAddress, 5_0000  ether);
        //运营
        _mint(_operatorAddress, 5_0000 ether);
        //空投锁仓合约地址
        _mint(_airdropLockAddress, 50_0000 ether);
        superNodeAddress = _superNodeAddress;
        mainNodeAddress = _mainNodeAddress;
        richNodeAddress = _richNodeAddress;
        liquidityAddress = _liquidityAddress;
        whitelistAddress = _whitelistAddress;
        stakingPoolAddress = _stakingPoolAddress;
        devAddress = _devAddress;
        operatorAddress = _operatorAddress;
        airdropLockAddress = _airdropLockAddress;

        //Mainnet
        // IPancakeRouter02 pancakeRouter = IPancakeRouter02(
        //     0x10ED43C718714eb63d5aA57B78B54704E256024E
        // );
        // // //生成交易对地址,token0为LLAW,token1为USDT，添加流动性时需按照此路径添加
        // //
        // pairAddress = IPancakeFactory(pancakeRouter.factory()).createPair(
        //     address(this),
        //     0x55d398326f99059fF775485246999027B3197955
        // );
        //Testnet
        IPancakeRouter02 pancakeRouter = IPancakeRouter02(
            0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3
        );
        // //生成交易对地址,token0为LLAW,token1为USDT，添加流动性时需按照此路径添加
        //
        pairAddress = IPancakeFactory(pancakeRouter.factory()).createPair(
            address(this),
            0x7ef95a0FEE0Dd31b22626fA2e10Ee6A223F8a684
        );
        //部署时默认把流动性添加地址添加到白名单
        feeWhitelist[liquidityAddress] = true;
        feeWhitelist[msg.sender] = true;
        //把PancakeSwapRouter地址添加到白名单
        feeWhitelist[whitelistAddress] = true;
        //把矿池地址添加到白名单
        feeWhitelist[stakingPoolAddress] = true;
        feeWhitelist[airdropLockAddress] = true;
        feeWhitelist[superNodeAddress] = true;
        feeWhitelist[mainNodeAddress] = true;
        feeWhitelist[richNodeAddress] = true;
        feeWhitelist[devAddress] = true;
        feeWhitelist[operatorAddress] = true;

        //初始化链ID
        INITIAL_CHAIN_ID = block.chainid;
        //初始化域分隔符
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    function setPairAddress(address addr) public onlyOwner {
        pairAddress = addr;
    }

    function addWhiteList(address addr) public onlyOwner {
        feeWhitelist[addr] = true;
    }

    function approve(address spender, uint256 amount)
        public
        virtual
        returns (bool)
    {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount)
        public
        virtual
        returns (bool)
    {
        _transfer(msg.sender, to, amount);
        return true;
    }

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual returns (bool) {
        uint256 allowed = allowance[from][msg.sender];
        // Saves gas for limited approvals.

        if (allowed != type(uint256).max)
            allowance[from][msg.sender] = allowed - amount;

        _transfer(from, to, amount);

        return true;
    }

    function permit(
        address owner,
        address spender,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        require(deadline >= block.timestamp, "PERMIT_DEADLINE_EXPIRED");

        // Unchecked because the only math done is incrementing
        // the owner's nonce which cannot realistically overflow.
        unchecked {
            address recoveredAddress = ecrecover(
                keccak256(
                    abi.encodePacked(
                        "\x19\x01",
                        DOMAIN_SEPARATOR(),
                        keccak256(
                            abi.encode(
                                keccak256(
                                    "Permit(address owner,address spender,uint256 value,uint256 nonce,uint256 deadline)"
                                ),
                                owner,
                                spender,
                                value,
                                nonces[owner]++,
                                deadline
                            )
                        )
                    )
                ),
                v,
                r,
                s
            );

            require(
                recoveredAddress != address(0) && recoveredAddress == owner,
                "INVALID_SIGNER"
            );

            allowance[recoveredAddress][spender] = value;
        }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return
            block.chainid == INITIAL_CHAIN_ID
                ? INITIAL_DOMAIN_SEPARATOR
                : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    keccak256(
                        "EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"
                    ),
                    keccak256(bytes(name)),
                    keccak256("1"),
                    block.chainid,
                    address(this)
                )
            );
    }

    function _mint(address to, uint256 amount) internal virtual {
        totalSupply += amount;
        unchecked {
            balanceOf[to] += amount;
        }
        emit Transfer(address(0), to, amount);
    }

    function _burn(address from, uint256 amount) internal virtual {
        totalDestroyAmount += amount;
        destroyAmount += amount;
        totalSupply -= amount;
        if (block.timestamp > startTime + 1 days) {
            dayDestroyAmount = destroyAmount;
            destroyAmount = 0;
            startTime = block.timestamp;
            if (IStakePool(stakingPoolAddress).updateReward(dayDestroyAmount)) {
                emit UpdateReward(dayDestroyAmount, block.timestamp);
            }
        }
        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
        unchecked {
            totalSupply -= amount;
        }

        emit Transfer(from, DEAD_ADDRESS, amount);
    }

    function setStartTime(uint256 _startTime) public onlyOwner {
        startTime = _startTime;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(balanceOf[from] >= amount, "TRANSFER_NOT_ENOUGH_FUNDS");
        //销毁到
        if (totalSupply < 21000 ether) {
            balanceOf[from] -= amount;
            balanceOf[to] += amount;
            emit Transfer(from, to, amount);
            return;
        }
        if (to == DEAD_ADDRESS) {
            balanceOf[from] -= amount;
            _burn(from, amount);
            return;
        }
        if (to != pairAddress && from != pairAddress) {
            //排除地址address(0),stakeingAddress,superNodeAddress,mainNodeAddress,richNodeAddress
            if (
                from != address(0) &&
                from != stakingPoolAddress &&
                from != superNodeAddress &&
                from != mainNodeAddress &&
                from != richNodeAddress &&
                from != airdropLockAddress &&
                inviter[to] == address(0)
            ) {
                inviter[to] = from;
            }
            //正常转账不扣手续费
            balanceOf[from] -= amount;
            balanceOf[to] += amount;
            emit Transfer(from, to, amount);
        } else {
            if (feeWhitelist[from]) {
                balanceOf[from] -= amount;
                balanceOf[to] += amount;
                emit Transfer(from, to, amount);
            } else {
                uint256 toBurn = (amount * 2) / 100;
                uint256 toSuperNodeFee = (amount * 1) / 100;
                uint256 toMainNodeFee = (amount * 75) / 10000;
                uint256 toRichNodeFee = (amount * 75) / 10000;
                uint256 toInviterFee = (amount * 5) / 1000;
                uint256 receiveAmount = (amount * 95) / 100;
                balanceOf[from] -= amount;
                _burn(from, toBurn);
                balanceOf[superNodeAddress] += toSuperNodeFee;
                emit Transfer(from, superNodeAddress, toSuperNodeFee);
                balanceOf[richNodeAddress] += toRichNodeFee;
                emit Transfer(from, richNodeAddress, toRichNodeFee);
                balanceOf[mainNodeAddress] += toMainNodeFee;
                emit Transfer(from, mainNodeAddress, toMainNodeFee);
                //买
                if (from == pairAddress) {
                    if (inviter[to] != address(0)) {
                        balanceOf[inviter[to]] += toInviterFee;
                        emit Transfer(from, inviter[to], toInviterFee);
                    } else {
                        _burn(from, toInviterFee);
                    }
                    //卖
                } else if (to == pairAddress) {
                    if (inviter[from] != address(0)) {
                        balanceOf[inviter[from]] += toInviterFee;
                        emit Transfer(from, inviter[from], toInviterFee);
                    } else {
                        _burn(from, toInviterFee);
                    }
                }
                balanceOf[to] += receiveAmount;
                emit Transfer(from, to, receiveAmount);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
interface IPancakeRouter01 {
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

interface IPancakeRouter02 is IPancakeRouter01 {
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

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;
interface IPancakeFactory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);

    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);

    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);

    function createPair(address tokenA, address tokenB) external returns (address pair);

    function setFeeTo(address) external;
    function setFeeToSetter(address) external;

    function INIT_CODE_PAIR_HASH() external view returns (bytes32);
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
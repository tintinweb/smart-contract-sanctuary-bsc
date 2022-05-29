// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity >=0.8.0;

// import "../pancakeswap_interface/IPancakeRouter.sol";

// import "../pancakeswap_interface/IPancakeFactory.sol";

/// @notice Modern and gas efficient ERC20 + EIP-2612 implementation.
/// @author Solmate (https://github.com/Rari-Capital/solmate/blob/main/src/tokens/ERC20.sol)
/// @author Modified from Uniswap (https://github.com/Uniswap/uniswap-v2-core/blob/master/contracts/UniswapV2ERC20.sol)
/// @dev Do not manually set balances without updating totalSupply, as the sum of all user balances must not exceed it.
contract LLAW {
    event Transfer(address indexed from, address indexed to, uint256 amount);
    event Approval(address indexed owner, address indexed spender, uint256 amount);
    address private _owner;
    string public name;
    string public symbol;
    uint8 public immutable decimals;
    uint256 public totalSupply;
    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;
    uint256 internal immutable INITIAL_CHAIN_ID;
    bytes32 internal immutable INITIAL_DOMAIN_SEPARATOR;
    mapping(address => uint256) public nonces;

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
    //技术与运营锁仓释放合约地址
    address private techLockAddress;
    //空投锁仓合约地址
    address private airdropLockAddress;
    //回购合约
    address public buyBackAddress;
    //超级节点分红地址
    address public superNodeAddress;
    //主节点分红合约
    address public mainNodeAddress;
    //财富节点分红合约
    address public richNodeAddress;
    //手续费白名单
    mapping(address => bool) private feeWhitelist;
    //邀请关系映射
    mapping(address => address) private inviter; //user=> inviter
    //记录第一次添加流动性时池子中两种币的存量
    // uint256 public firstToken0;
    // uint256 public firstToken1;
    // //记录销毁数量
    uint256 public destroyAmount;
    //开始时间
    uint256 public startTime;
    //日销毁量
    uint256 public dayDestroyAmount;

    constructor() {
        name = "LLAW DAO TOKEN";
        symbol = "LLAW";
        decimals = 18;
        whitelistAddress = 0x85c2A31aa13c348f74b7FcF073320A8d77cb005B;
        liquidityAddress = 0xa44d14c40018DF7e28157D91dbee5fC882fA027f;
        techLockAddress = 0x9137866e451943b53794E3961c5bc5Fb4C941A43;
        airdropLockAddress = 0x4D538c554F724d139A21A17011e3739073857430;
        buyBackAddress = 0x10A7339233665ec0b3bfC0c467740B765c8a4737;
        stakingPoolAddress = 0x00AcE9686bFcc468A0D5C3B164DB9470267fe94e;
        //TODO
        superNodeAddress = 0x8dbAe5302413Ed8D079Dab53a81fFAe3F8Bb1a67;
        //TODO
        mainNodeAddress = 0x1acabd9C96afbB062309054AF0e385A822796601;

        richNodeAddress = 0xa977A90295BebD28CCb2D5902cF00e37A037fE0c;

        //白名单
        _mint(whitelistAddress, 20_0000 * 10 ** 18);
        //流动性添加地址
        _mint(liquidityAddress, 20_0000 * 10 ** 18);
        //技术与运营锁仓合约地址
        _mint(techLockAddress, 10_0000 * 10 ** 18);
        //空投锁仓合约地址
        _mint(airdropLockAddress, 50_0000 * 10 ** 18);
        //矿池合约地址
        _mint(stakingPoolAddress, 2000_0000 * 10 ** 18);

        //test
        // _mint(0x9192Ec52DcEe2C738D95e4511FdA90DE4e146666, 10_0000 * 10 ** 18);


        //测试网
        // pancakeRouter = IPancakeRouter02(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        // pancakeFactory = IPancakeFactory(pancakeRouter.factory());
        // //生成交易对地址,token0为LLAW,token1为ETH，添加流动性时需按照此路径添加
        // pairAddress = pancakeFactory.createPair(address(this), pancakeRouter.WETH());
        _owner = msg.sender;
        //部署时默认把流动性添加地址添加到白名单
        feeWhitelist[liquidityAddress] = true;
        feeWhitelist[msg.sender] = true;
        //把PancakeSwapRouter地址添加到白名单
        feeWhitelist[whitelistAddress] = true;
        //把矿池地址添加到白名单
        feeWhitelist[stakingPoolAddress] = true;

        //初始化链ID
        INITIAL_CHAIN_ID = block.chainid;
        //初始化域分隔符
        INITIAL_DOMAIN_SEPARATOR = computeDomainSeparator();
    }

    modifier onlyOwner() {
        require(msg.sender == _owner);
        _;
    }
    function setPairAddress(address addr) public onlyOwner {
        pairAddress = addr;
    }

    function approve(address spender, uint256 amount) public virtual returns (bool) {
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    function transfer(address to, uint256 amount) public virtual returns (bool) {
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

        if (allowed != type(uint256).max) allowance[from][msg.sender] = allowed - amount;

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

        require(recoveredAddress != address(0) && recoveredAddress == owner, "INVALID_SIGNER");

        allowance[recoveredAddress][spender] = value;
    }

        emit Approval(owner, spender, value);
    }

    function DOMAIN_SEPARATOR() public view virtual returns (bytes32) {
        return block.chainid == INITIAL_CHAIN_ID ? INITIAL_DOMAIN_SEPARATOR : computeDomainSeparator();
    }

    function computeDomainSeparator() internal view virtual returns (bytes32) {
        return
        keccak256(
            abi.encode(
                keccak256("EIP712Domain(string name,string version,uint256 chainId,address verifyingContract)"),
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
        balanceOf[from] -= amount;

        // Cannot underflow because a user's balance
        // will never be larger than the total supply.
    unchecked {
        totalSupply -= amount;
    }

        emit Transfer(from, address(0), amount);
    }

    function setStartTime(uint256 _startTime) public {
        startTime = _startTime;
    }

    function _transfer(address from, address to, uint256 amount) internal virtual {
        require(balanceOf[from] >= amount, "TRANSFER_NOT_ENOUGH_FUNDS");
        if(to== address(0x000000000000000000000000000000000000dEaD)){
            destroyAmount += amount;
            if(block.timestamp > startTime + 1 hours){
                dayDestroyAmount = destroyAmount;
                destroyAmount = 0;
                startTime = block.timestamp;
            }
        }
        if(to!=address(pairAddress)&&from!=address(pairAddress)){
            //正常转账不扣手续费
            balanceOf[from] -= amount;
            balanceOf[to] += amount;
            emit Transfer(from, to, amount);
        }else{
            if(feeWhitelist[from]) {
                balanceOf[from] -= amount;
                balanceOf[to] += amount;
                emit Transfer(from, to, amount);
            }else{
                //扣手续费
                uint256 toBuyBackFee = amount * 2 / 100;
                uint256 toSuperNodeFee = amount * 1 / 100;
                uint256 toMainNodeFee = amount * 75 /10000;
                uint256 toRichNodeFee = amount * 75 /10000;
                uint256 toInviterFee = amount * 5/1000;
                uint256 receiveAmount = amount * 95 /100;
                balanceOf[from] -= amount;
                balanceOf[buyBackAddress] += toBuyBackFee;
                balanceOf[superNodeAddress] += toSuperNodeFee;
                emit Transfer(from, superNodeAddress, toSuperNodeFee);
                balanceOf[richNodeAddress] += toRichNodeFee;
                balanceOf[mainNodeAddress] += toMainNodeFee;
                if(inviter[from]!=address(0)&&inviter[from]!=address(pairAddress)&&inviter[from]!=address(stakingPoolAddress)){
                    balanceOf[inviter[from]] += toInviterFee;
                }else{
                    balanceOf[0x000000000000000000000000000000000000dEaD] += toInviterFee;
                    emit Transfer(from, 0x000000000000000000000000000000000000dEaD, toInviterFee);
                    inviter[to] = from;
                }
                balanceOf[to] +=receiveAmount;
                emit Transfer(from, to, amount);
            }
        }

    }
}
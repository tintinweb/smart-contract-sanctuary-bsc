/// @title WHOToken
/// @author AEdge
/// @dev WHO代币合约
// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.8.0;
// BEP20
import "@sphynxswap/sphynx-swap-lib/contracts/token/BEP20/BEP20.sol";
// 权限库
import "solidity_lib/Permission/Permission_abstract.sol";
// 时间库
import "solidity_lib/Time/time.sol";
// Factory
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Factory.sol";
// Pair
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";
// Router
import "@uniswap/v2-periphery/contracts/interfaces/IUniswapV2Router02.sol";
// UniswapV2Library
import "../../library/V2Library/UniswapV2Library.sol";
// 数据库
import "../../interface/who_sql/Iwhodb.sol";
// 数据库的数据结构库
import "../../library/LWHO.sol";
import '@uniswap/lib/contracts/libraries/TransferHelper.sol';
import '../../interface/whtc/IWHTC.sol';

contract WHOToken is BEP20, permission{
    address daoAddress;
    address USDTAddress;
    address public routerAddress;
    address public uniswapV2Pair;
    // address PoundageAddress;
    // address returnLiquidtyWHOAddress;
    // address returnLiquidtyWHDAddress;
    address[3] returnAddress; // 0 回流WHO地址，1回流WHD地址，2手续费地址
    address WHTCAddress;
    uint public endPoolAmount;
    bool isSolidity;
    bytes4 private constant SELECTOR = bytes4(keccak256(bytes('transfer(address,uint256)')));
    IWhoSql db;
    IUniswapV2Router02 router;
    // uint swapPoundage; //交易手续费
    // uint returnLiquidityFeeWHO; // 回流WHO
    // uint returnLiquidityFeeWHD; // 回流WHD
    uint[5] allFee; // 0 回流WHO倍率 1回流WHD倍率 2 打黑洞 3 铸造 4 交易手续费
    // uint burnFee; // 打黑洞
    // uint mintCoinFee;  // 铸造
    bool isTransferDao;
    modifier isTrade{
        // require(IWhoSql(db.getSql()[2]).getIsTrade() == true&& IWhoSql(db.getSql()[2]).getInitTransWhiteList(msg.sender) == false,"You don't have access.");
        LWHO.isAccess(IWhoSql(db.getSql()[2]),msg.sender);
        _;    
    }
    constructor(address[] memory pool) BEP20("WHO","WHO") {
        USDTAddress = pool[4];
        routerAddress = pool[5];
        router = IUniswapV2Router02(routerAddress);
        endPoolAmount = 20 * 10000 * 10 ** decimals();
        returnAddress[2] = pool[3];
        _mint(pool[0],80 * 10000 * 10 ** decimals());
        _mint(pool[1],20 * 10000 * 10 ** decimals());
        _mint(pool[2],30 * 10000 * 10 ** decimals());
        returnAddress[0] = pool[1];
        returnAddress[1] = pool[8];
        uniswapV2Pair = IUniswapV2Factory(router.factory()).createPair(address(this),USDTAddress);
        db = IWhoSql(pool[6]);
        setPermissioin(pool[7]);
        allFee[4] = 9;
        allFee[0] = 3;
        allFee[1] = 6;
        allFee[2] = 3;
        allFee[3] = 3;
        WHTCAddress = pool[9];
    }
    function setWHTCAddress(address _address) public payable isAdmin(msg.sender){
        WHTCAddress = _address;
    }
    // 设置手续费
    function setSwapPoundage(uint ratio) public payable isAdmin(msg.sender){
        allFee[4] = ratio;
    }
    // 设置WHO回流地址
    function setReturnLiquidityWHOAddress(address _address) public payable isAdmin(msg.sender){
        returnAddress[0] = _address;
    }
    // 设置WHD回流地址`-+

    function setReturnLiquidityWHDAddress(address _address) public payable isAdmin(msg.sender){
        returnAddress[1] = _address;
    }
    // 设置回流
    function setAllFee(uint[5] memory ratio) public payable isAdmin(msg.sender){
        allFee = ratio;
    }
    // function setReturnLiquidityFeeWHD(uint ratio) public payable isAdmin(msg.sender){
    //     allFee[1] = ratio;
    // }
    // // 设置销毁
    // function setBurnFee(uint ratio) public payable isAdmin(msg.sender){
    //     allFee[2] = ratio;
    // }
    // // 设置铸造金额
    // function setMintFee(uint ratio) public payable isAdmin(msg.sender){
    //     allFee[3] = ratio;
    // }
    // 获取当前各类销毁金额
    function getFee() public view returns (uint[5] memory ratios){
        // ratios[0] = allFee[4];
        // ratios[1] = allFee[0];
        // ratios[2] = allFee[1];
        // ratios[3] = allFee[2];
        // ratios[4] = allFee[3];
        return allFee;
    }
    // @dev 设置Dao合约地址
    function setDaoContract(address dao) public payable isAdmin(msg.sender){
        daoAddress = dao;
        if(isTransferDao == false){
            // 算力矿池
            _mint(daoAddress,370 * 10000 * 10 ** decimals());
            // 添加算力矿池记录
            db.setCalculatePool(370 * 10000 * 10 ** decimals(),"add");
            db.setTotalMintAmount(500 * 10000 * 10 ** decimals());
        }
    }
    // 合约内部转账
    function _safeTransfer(address token, address to, uint value) private {
        globalSend(token,to,value,SELECTOR);
    }
    // function _safeApprove(address token,address to,uint value) private {
    //     (bool success, bytes memory data) = token.call(abi.encodeWithSelector(APPROVESELECTOR, to, value));
    //     require(success && (data.length == 0 || abi.decode(data, (bool))), 'WHOToken: approve failed');
    // }

    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "WHOToken: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }
    //  @dev 重写transferFrom
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public override virtual returns (bool) {
        address spender = msg.sender;
        _spendAllowance(from, spender, amount);
        fee(from,to,amount);
        return true;
    }
    function fee(address from,address to,uint amount) internal virtual isTrade{
        if(isSolidity == false){
            if(from == routerAddress|| to == uniswapV2Pair || from == uniswapV2Pair){
                _transfer(from, address(this), amount);
                // _transfer(address(this), to, amount);
                _transfer(address(this),daoAddress, amount / 100 * 5);
                _transfer(address(this),daoAddress, amount / 100 * 3);
                uint _total = db.getLpTotal("WHO");
                address[] memory users = db.getLpUser();
                if(_total>200000 * 10 **18){
                    uint _newTotal = _total - 200000 * 10 **18;
                    for(uint i = 0;i<users.length;i++){
                        uint lpTotal = db.getUserLpTotal(users[i], "WHO");
                        IWhoSql(db.getSql()[2]).addAddressTypeIncome(users[i],"lp",LWHO.TokenType.WHO,(amount / 100 * 3) * lpTotal/_newTotal);
                        db.setWalletNum(users[i],LWHO.TokenType.WHO,(amount / 100 * 3) * lpTotal/_newTotal,"add");
                    }
                }
                _burn(address(this), amount / 100 * 2);
                db.setBurnedTotalAmount(amount / 100 * 2);
                _transfer(address(this), returnAddress[2], amount / 100 * 2);
                db.addPoolAmount("WHO",amount / 100 * 2);
                _transfer(address(this),daoAddress, amount / 100 * 1);
                LWHO.partner[] memory part = IWhoSql(db.getSql()[1]).getGeneralPartner();
                (LWHO.partner[] memory npart,uint b)= LWHO.getPart(part);
                // uint b = 0;
                // for(uint a=0;a<part.length;a++){
                //     if(part[a].isExist){
                //         npart[b] = part[a];
                //         b++;
                //     }
                // }
                for(uint c=0;c<npart.length;c++){
                    IWhoSql(db.getSql()[2]).addAddressTypeIncome(npart[c].user,"community",LWHO.TokenType.WHO,(amount/100 * 1)/b);
                    db.setWalletNum(npart[c].user,LWHO.TokenType.WHO,(amount / 100 * 1)/b,"add");
                }
                _transfer(address(this), to, amount / 100 * 87);
            }else{
                _transfer(from, to, amount);
            }
        }else{
            _transfer(from, to, amount);
        }
    }
    function transfer(address to, uint256 amount) public override virtual returns (bool) {
        fee(msg.sender,to,amount);
        return true;
    }
    // 删除流动性 (删除全部)
    function removeLiquidityUser(uint liquidity) public payable isTrade{
        isSolidity = true;
        IUniswapV2Pair(uniswapV2Pair).transferFrom(msg.sender,address(this),liquidity);
        // IUniswapV2Pair(uniswapV2Pair).approve(routerAddress,liquidity);
        bytes4 approve = bytes4(keccak256(bytes('approve(address,uint256)')));
        globalSend(uniswapV2Pair,routerAddress,liquidity,approve);
        (uint amountA,uint amountB) = router.removeLiquidity(address(this),USDTAddress,liquidity,0,0,address(this),block.timestamp);
        if(IWhoSql(db.getSql()[1]).isTradingWhiteList(msg.sender) == false&&IWhoSql(db.getSql()[1]).isOfficeAddress(msg.sender) == false){
            _safeTransfer(address(this),returnAddress[0],amountA * allFee[0] / 100); // 回流WHO
            _safeTransfer(address(this),returnAddress[1],amountA * allFee[1] / 100); // 回流WHD
            _safeTransfer(USDTAddress,returnAddress[0],amountB * allFee[0] / 100); // 回流WHO
            _safeTransfer(USDTAddress,returnAddress[1],amountB * allFee[1] / 100); //回流WHD
            _safeTransfer(address(this),msg.sender,amountA * (100 - allFee[4]) / 100); // 交易手续费
            _safeTransfer(USDTAddress,msg.sender,amountB * (100 - allFee[4]) / 100);// 交易手续费
            db.addrmLpRecord(msg.sender,LWHO.LpUint(block.timestamp,amountA * (100 - allFee[4]) / 100,amountB * (100 - allFee[4]) / 100,"WHO"));
        }else{
            _safeTransfer(address(this),msg.sender,amountA);
            _safeTransfer(USDTAddress,msg.sender,amountB);
            db.addrmLpRecord(msg.sender,LWHO.LpUint(block.timestamp,amountA,amountB,"WHO"));
        }
        isSolidity = false;
    }
    // @dev 增加流动性方法 amountADesired 内部方法 使用前需要转入部分 USDT 到合约
    function addLiquidityUser(uint tokenAmount,uint USDTAmount) public payable isTrade{
        isSolidity = true;
        uint[3] memory YMD = timeStamp.getYMD(block.timestamp);
        _transfer(msg.sender,address(this),tokenAmount);
        IBEP20(USDTAddress).transferFrom(msg.sender, address(this), USDTAmount);
        if(!IWhoSql(db.getSql()[1]).isTradingWhiteList(msg.sender)){
            if(!IWhoSql(db.getSql()[1]).isOfficeAddress(msg.sender)){
                // _safeTransfer(address(this), PoundageAddress, tokenAmount / 100 * swapPoundage);
                // _safeTransfer(USDTAddress,PoundageAddress,USDTAmount / 100 * swapPoundage);
                _safeTransfer(address(this), returnAddress[0], tokenAmount / 100 * allFee[0]); // 回流WHO
                uint burnAmount = tokenAmount/ 100 * allFee[2];
                _burn(address(this),burnAmount); //销毁
                db.setBurnedTotalAmount(burnAmount);
                // 铸造WHTC接口
                uint makeAmount = tokenAmount / 100 * allFee[3];
                uint LiquidityAmount = tokenAmount / 100 * (100 - allFee[4]); // 交易手续费
                IWHTC(WHTCAddress).make(makeAmount, msg.sender);
                _burn(address(this),makeAmount);
                db.setBurnedTotalAmount(makeAmount);
                // 转U到指定钱包进行添加流动性
                _safeTransfer(USDTAddress, returnAddress[0], USDTAmount / 100 * allFee[0]); //回流WHO
                _safeTransfer(USDTAddress, returnAddress[1], USDTAmount / 100 * allFee[1]); // 回流WHD
                IBEP20(address(this)).approve(routerAddress,LiquidityAmount);
                IBEP20(USDTAddress).approve(routerAddress,USDTAmount);
                db.setUserLPStartTime(msg.sender,block.timestamp);
                router.addLiquidity(address(this), USDTAddress, LiquidityAmount, USDTAmount / 100 * (100 - allFee[4]), 0, 0, msg.sender, block.timestamp);
                db.addLpRecord(msg.sender, LWHO.LpUint(block.timestamp,LiquidityAmount,USDTAmount / 100 * (100 - allFee[4]),"WHO"));
            }else{
                IBEP20(address(this)).approve(routerAddress,tokenAmount);
                IBEP20(USDTAddress).approve(routerAddress,USDTAmount);
                router.addLiquidity(address(this), USDTAddress, tokenAmount, USDTAmount, 0, 0, msg.sender, block.timestamp);
                db.addLpRecord(msg.sender, LWHO.LpUint(block.timestamp,tokenAmount,USDTAmount,"WHO"));
            }
        }else{
            IBEP20(address(this)).approve(routerAddress,tokenAmount);
            IBEP20(USDTAddress).approve(routerAddress,USDTAmount);
            router.addLiquidity(address(this), USDTAddress, tokenAmount, USDTAmount, 0, 0, msg.sender, block.timestamp);
            db.addLpRecord(msg.sender, LWHO.LpUint(block.timestamp,tokenAmount,USDTAmount,"WHO"));
        }
        db.addAddLpUser(msg.sender);
        db.addDayLPCount(YMD[0],YMD[1],YMD[2],tokenAmount);
        isSolidity = false;
    }
    function globalSend(address token,address to,uint value,bytes4 sendData) internal {
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(sendData, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'WHOToken: send failed');
    }
    // @dev 代币与代币交换
    function swapTokensForExactTokens(uint amountOut,address[] memory tokens) public isTrade{
        isSolidity = true;
        string memory tokenName;
        string memory toName;
        if(tokens[0] == address(this)&&tokens[1] == USDTAddress){
            tokenName = "WHO";
            toName = "USDT";
        }else if(tokens[0] == USDTAddress&&tokens[1] == address(this)){
            tokenName = "USDT";
            toName = "WHO";
        }else{
            revert("This token is not supported");
        }
        IBEP20(tokens[0]).transferFrom(msg.sender, address(this), amountOut);
        uint remain;
        if(!IWhoSql(db.getSql()[1]).isTradingWhiteList(msg.sender)&&!IWhoSql(db.getSql()[1]).isOfficeAddress(msg.sender)){
            distributionFee(tokens[0],msg.sender,amountOut);
            remain = amountOut / 100 * (100 - 13);
        }else{
            remain = amountOut;
        }
        IBEP20(tokens[0]).approve(routerAddress, remain);
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(remain, 0, tokens,msg.sender, block.timestamp);
        db.addExchangeRecord(msg.sender,LWHO.exChangeUint({
            createTime:block.timestamp,
            amount:amountOut,
            tokenName:tokenName,
            toName:toName
        }));
        isSolidity = false;
    }
    // 父级是否满足条件
    function fatherMeet(address _token,address user,uint amount) internal {
        uint fatherAmount = balanceOf(user);
        (uint112 usdtTotal,uint112 whoTotal,) = IUniswapV2Pair(uniswapV2Pair).getReserves();
        uint whoAmount = (usdtTotal * 10 ** decimals())/whoTotal;
        uint plgWho = db.getPlgTokenNum(user,"WHO");
        uint LpTotal = db.getUserLpTotal(user,"USDT");
        if(fatherAmount>=whoAmount * 500){ 
            if(plgWho>100&&LpTotal>100){
                _safeTransfer(_token, user, amount);
            }else{
                _safeTransfer(_token, daoAddress, amount);
            }
        }else{
            _safeTransfer(_token, daoAddress, amount);
        }
    }
    // 分配手续费 user 用户 amount 转账总费用
    function distributionFee(address _token,address user,uint amount) internal {
        address[] memory father = IWhoSql(db.getSql()[1]).getFathers(user);
        if(father[0]!=address(0)){
            for(uint i = 0;i<father.length;i++){
                uint _amount = LWHO.fatherMeetFee(amount,i);
                if(father[i]!=address(0)){
                    if(_amount!=0){
                        fatherMeet(_token,father[i],_amount);
                    }
                }else{
                    _safeTransfer(_token,daoAddress,_amount);
                }
                // if(i>=0&&i<3){
                //     fatherMeet(_token,father[i],amount / 100 * 1);
                // }else if(i>=3&&i<5){
                //     fatherMeet(_token,father[i],amount / 1000 * 5);
                // }else if(i>=5&&i<10){
                //     fatherMeet(_token,father[i],amount / 1000 * 2);
                // }
            }
        }else{
            _safeTransfer(_token, daoAddress, amount / 100 * 5);
        }
        _safeTransfer(_token, daoAddress, amount / 100 * 3);
        uint _total = db.getLpTotal("WHO");
        address[] memory users = db.getLpUser();
        if(_total>200000 * 10 **18){
            uint _newTotal = _total - 200000 * 10 **18;
            for(uint i = 0;i<users.length;i++){
                uint lpTotal = db.getUserLpTotal(users[i], "WHO");
                LWHO.TokenType _tokenType;
                if(_token == address(this)){
                    _tokenType = LWHO.TokenType.WHO;
                }else{
                    _tokenType = LWHO.TokenType.USDT;
                }
                IWhoSql(db.getSql()[2]).addAddressTypeIncome(users[i],"lp",_tokenType,(amount / 100 * 3) * lpTotal/_newTotal);
                db.setWalletNum(users[i],_tokenType,(amount / 100 * 3)* lpTotal/_newTotal,"add");
            }
        }
        if(_token == address(this)){
            _burn(address(this), amount / 100 * 2); //
            db.setBurnedTotalAmount(amount / 100 * 2);
        }else{
            _safeTransfer(_token, daoAddress, amount / 100 * 2);
        }
        _safeTransfer(_token,returnAddress[0],amount / 100 * 2);
        // _transfer(address(this), returnAddress[0], amount / 100 * 2);
        db.addPoolAmount("WHO",amount / 100 * 2);
        // _transfer(address(this),daoAddress, amount / 100 * 1);
        _safeTransfer(_token,daoAddress,amount / 100 * 1);
        LWHO.partner[] memory part = IWhoSql(db.getSql()[1]).getGeneralPartner();
        (LWHO.partner[] memory npart,uint b) = LWHO.getPart(part);
        // LWHO.partner[] memory npart = new LWHO.partner[](part.length);
        // uint b = 0;
        // for(uint a=0;a<part.length;a++){
        //     if(part[a].isExist){
        //         npart[b] = part[a];
        //         b++;
        //     }
        // }
        for(uint c=0;c<npart.length;c++){
            LWHO.TokenType _typeToken;
            if(_token == address(this)){
                // db.addSupernumeraryIncome("WHO",npart[c].user,(amount / 100 * 1)/b);
                _typeToken = LWHO.TokenType.WHO;
            }else{
                // db.addSupernumeraryIncome("USDT",npart[c].user,(amount / 100 * 1)/b);
                // IWhoSql(db.getSql()[2]).addAddressTypeIncome(npart[c].user,"community",LWHO.TokenType.USDT,(amount/100 * 1)/b);
                // db.setWalletNum(npart[c].user,LWHO.TokenType.USDT,(amount/100 * 1)/b,"add");
                _typeToken = LWHO.TokenType.USDT;
            }
            IWhoSql(db.getSql()[2]).addAddressTypeIncome(npart[c].user,"community",_typeToken,(amount/100 * 1)/b);
            db.setWalletNum(npart[c].user,_typeToken,(amount/100 * 1)/b,"add");
        }
    }
    // 提U接口(添加流动性会留下部分U，这部分U用于人工回流底池用)
    function withdrawalUSDT(uint amount) public payable isAdmin(msg.sender){
        _safeTransfer(USDTAddress,daoAddress,amount);
    }
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

import '../../access/Ownable.sol';
// import '../../GSN/Context.sol';
import './IBEP20.sol';
import '../../math/SafeMath.sol';
import '../../utils/Address.sol';

/**
 * @dev Implementation of the {IBEP20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {BEP20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-BEP20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin guidelines: functions revert instead
 * of returning `false` on failure. This behavior is nonetheless conventional
 * and does not conflict with the expectations of BEP20 applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IBEP20-approve}.
 */
contract BEP20 is IBEP20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    /**
     * @dev Sets the values for {name} and {symbol}, initializes {decimals} with
     * a default value of 18.
     *
     * To select a different value for {decimals}, use {_setupDecimals}.
     *
     * All three of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_){
        _name = name_;
        _symbol = symbol_;
        _decimals = 18;
    }

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external override view returns (address) {
        return owner();
    }

    /**
     * @dev Returns the token name.
     */
    function name() public override view returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the token decimals.
     */
    function decimals() public override view returns (uint8) {
        return _decimals;
    }

    /**
     * @dev Returns the token symbol.
     */
    function symbol() public override view returns (string memory) {
        return _symbol;
    }

    /**
     * @dev See {BEP20-totalSupply}.
     */
    function totalSupply() public override view returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {BEP20-balanceOf}.
     */
    function balanceOf(address account) public override view returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {BEP20-transfer}.
     *
     * Requirements:
     *
     * - `recipient` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address recipient, uint256 amount) public override virtual returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    /**
     * @dev See {BEP20-allowance}.
     */
    function allowance(address owner, address spender) public override view returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {BEP20-approve}.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    /**
     * @dev See {BEP20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {BEP20};
     *
     * Requirements:
     * - `sender` and `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     * - the caller must have allowance for `sender`'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override virtual returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(amount, 'BEP20: transfer amount exceeds allowance')
        );
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public returns (bool) {
        _approve(msg.sender, spender, _allowances[msg.sender][spender].add(addedValue));
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {BEP20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public returns (bool) {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(subtractedValue, 'BEP20: decreased allowance below zero')
        );
        return true;
    }

    /**
     * @dev Creates `amount` tokens and assigns them to `msg.sender`, increasing
     * the total supply.
     *
     * Requirements
     *
     * - `msg.sender` must be the token owner
     */
    function mint(uint256 amount) public onlyOwner returns (bool) {
        _mint(msg.sender, amount);
        return true;
    }

    /**
     * @dev Destroys `amount` tokens from `msg.sender`, decreasing the total supply.
     *
     */
    function burn(uint256 amount) public returns (bool) {
        _burn(msg.sender, amount);
        return true;
    }

    /**
     * @dev Moves tokens `amount` from `sender` to `recipient`.
     *
     * This is internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `sender` cannot be the zero address.
     * - `recipient` cannot be the zero address.
     * - `sender` must have a balance of at least `amount`.
     */
    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal virtual {
        require(sender != address(0), 'BEP20: transfer from the zero address');
        require(recipient != address(0), 'BEP20: transfer to the zero address');

        _balances[sender] = _balances[sender].sub(amount, 'BEP20: transfer amount exceeds balance');
        _balances[recipient] = _balances[recipient].add(amount);
        emit Transfer(sender, recipient, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements
     *
     * - `to` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: mint to the zero address');

        _totalSupply = _totalSupply.add(amount);
        _balances[account] = _balances[account].add(amount);
        emit Transfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal {
        require(account != address(0), 'BEP20: burn from the zero address');

        _balances[account] = _balances[account].sub(amount, 'BEP20: burn amount exceeds balance');
        _totalSupply = _totalSupply.sub(amount);
        emit Transfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner`s tokens.
     *
     * This is internal function is equivalent to `approve`, and can be used to
     * e.g. set automatic allowances for certain subsystems, etc.
     *
     * Emits an {Approval} event.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     * - `spender` cannot be the zero address.
     */
    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) internal {
        require(owner != address(0), 'BEP20: approve from the zero address');
        require(spender != address(0), 'BEP20: approve to the zero address');

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`.`amount` is then deducted
     * from the caller's allowance.
     *
     * See {_burn} and {_approve}.
     */
    function _burnFrom(address account, uint256 amount) internal {
        _burn(account, amount);
        _approve(
            account,
            msg.sender,
            _allowances[account][msg.sender].sub(amount, 'BEP20: burn amount exceeds allowance')
        );
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import './Permission_interface.sol';
abstract contract permission{
    IPermission public Perm;
    address permissionAddress;
    // 合约是否为所有者
    modifier _owner{
        Perm._Owner();
        _;
    }
    // 信息调用者是否为所有者
    modifier isOwner(address user){
        Perm._IsOwner(user);
        _;
    }
    // 合约是否为管理员
    modifier _admin() {
        Perm._Admin();
        _;
    }
    // 信息调用者是否为管理员
    modifier isAdmin(address user){
        Perm._IsAdmin(user);
        _;
    }
    // 合约是否为封禁对象
    modifier _ban(){
        Perm._Ban();
        _;
    }
    // 信息调用者是否为封禁对象
    modifier isBan(address user){
        Perm._IsBan(user);
        _;
    }
    // 合约是否为数据库操控者
    modifier _sql(){
        Perm._Sql();
        _;
    }
    // 信息调用者是否为数据库操控者
    modifier isSql(address user){
        Perm._IsSql(user);
        _;
    }
    function setPermissioin(address _address) internal {
        Perm = IPermission(_address);
    }
}

// SPDX-License-Identifier: MIT
/* 
    时间库：
    现有方法：
    formatHms(uint timestamp) 
    返回值：
    uint[] 0：时 1：分 2：秒
 */
pragma solidity ^0.8.0;
library timeStamp {    
    // 求一天内的时分秒
    function formatTime(uint timestamp) internal pure returns (uint[3] memory time){
        timestamp = ((timestamp % (1 days * 365)) % (1 days * 30)) % 1 days;
        uint H = timestamp / 3600;
        timestamp = timestamp % 3600;
        uint m = timestamp / 60;
        timestamp = timestamp % 60;
        uint s = timestamp;
        // 增加时区
        H = H + 8; 
        if(H>=24){
            H = H - 24;
        }
        time[0] = H;
        time[1] = m;
        time[2] = s;
    }
    // 默认0时区
    function getYMD(uint timestamp) internal pure returns(uint[3] memory time){
        return getYMD(timestamp,0);
    }
    // 求年月日
    function getYMD(uint timestamp,uint timeZone) internal pure returns(uint[3] memory time){
        timestamp = timestamp + timeZone * 1 hours; // UTC时区
        // 润年
        uint8[12] memory leapYear = [31,29,31,30,31,30,31,31,30,31,30,31];
        // 平年
        uint8[12] memory noleapYear = [31,28,31,30,31,30,31,31,30,31,30,31];
        uint totalDay = timestamp / 1 days;
        uint Year = 1970 + (totalDay / 365);
        bool isLeap;
        if(Year % 4 == 0&&Year%100!=0){
            isLeap = true;
        }else if(Year % 400 != 0&&Year%100 == 0){
            isLeap = false;
        }else if(Year % 400 == 0){
            isLeap = true;
        }else{
            isLeap = false;
        }
        uint Month;
        uint Day;
        uint tDay;
        bool isDay;
        if(isLeap){
            tDay = totalDay - ((Year-1970) * 366);
            for(uint i = 0;i<12;i++){
                if(tDay > leapYear[i]){
                    tDay -= leapYear[i];
                }else{
                    if(!isDay){
                        isDay = true;
                        Day = tDay;
                        Month = i + 1;
                    }
                }
            }
            if(Day<=12){
                time[2] = leapYear[Month-1] - (12 - Day);
            }else{
                time[2] = Day - 12;
            }
        }else{
            tDay = totalDay - ((Year-1970) * 365);
            for(uint i=0;i<12;i++){
                if(tDay > noleapYear[i]){
                    tDay -= noleapYear[i];
                }else{
                    if(!isDay){
                        isDay = true;
                        Day = tDay;
                        Month = i + 1;
                    }
                }
            }
            if(Day<12){
                time[2] = noleapYear[Month-1] - (11 - Day);
                Month = Month - 1;
            }else if(Day == 12){
                time[2] = noleapYear[Month-1];
            }else{
                time[2] = Day - 12;
            }
        }
        time[0] = Year;
        time[1] = Month;
    }
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

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

// SPDX-License-Identifier: MIT
pragma solidity >=0.5.0;

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

    event Mint(address indexed sender, uint amount0, uint amount1);
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

    function mint(address to) external returns (uint liquidity);
    function burn(address to) external returns (uint amount0, uint amount1);
    function swap(uint amount0Out, uint amount1Out, address to, bytes calldata data) external;
    function skim(address to) external;
    function sync() external;

    function initialize(address, address) external;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

import './IUniswapV2Router01.sol';

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

/**
由于原生的uniswap中pairFor方法对于solidity0.8.0以上的版本不兼容 故单独nachul/ai作为library
 */
// SPDX-License-Identifier: UNLICENSED
pragma solidity >=0.5.0;
import "@sphynxswap/sphynx-swap-lib/contracts/math/SafeMath.sol";
import "@uniswap/v2-core/contracts/interfaces/IUniswapV2Pair.sol";

library UniswapV2Library {
    using SafeMath for uint;

    // returns sorted token addresses, used to handle return values from pairs sorted in this order
    function sortTokens(address tokenA, address tokenB) internal pure returns (address token0, address token1) {
        require(tokenA != tokenB, 'UniswapV2Library: IDENTICAL_ADDRESSES');
        (token0, token1) = tokenA < tokenB ? (tokenA, tokenB) : (tokenB, tokenA);
        require(token0 != address(0), 'UniswapV2Library: ZERO_ADDRESS');
    }

    // fetches and sorts the reserves for a pair
    function getReserves(address tokenA, address tokenB,address pair) internal view returns (uint reserveA, uint reserveB) {
        (address token0,) = sortTokens(tokenA, tokenB);
        (uint reserve0, uint reserve1,) = IUniswapV2Pair(pair).getReserves();
        (reserveA, reserveB) = tokenA == token0 ? (reserve0, reserve1) : (reserve1, reserve0);
    }

    // given some amount of an asset and pair reserves, returns an equivalent amount of the other asset
    function quote(uint amountA, uint reserveA, uint reserveB) internal pure returns (uint amountB) {
        require(amountA > 0, 'UniswapV2Library: INSUFFICIENT_AMOUNT');
        require(reserveA > 0 && reserveB > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        amountB = amountA.mul(reserveB) / reserveA;
    }

    // given an input amount of an asset and pair reserves, returns the maximum output amount of the other asset
    function getAmountOut(uint amountIn, uint reserveIn, uint reserveOut) internal pure returns (uint amountOut) {
        require(amountIn > 0, 'UniswapV2Library: INSUFFICIENT_INPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint amountInWithFee = amountIn.mul(997);
        uint numerator = amountInWithFee.mul(reserveOut);
        uint denominator = reserveIn.mul(1000).add(amountInWithFee);
        amountOut = numerator / denominator;
    }

    // given an output amount of an asset and pair reserves, returns a required input amount of the other asset
    function getAmountIn(uint amountOut, uint reserveIn, uint reserveOut) internal pure returns (uint amountIn) {
        require(amountOut > 0, 'UniswapV2Library: INSUFFICIENT_OUTPUT_AMOUNT');
        require(reserveIn > 0 && reserveOut > 0, 'UniswapV2Library: INSUFFICIENT_LIQUIDITY');
        uint numerator = reserveIn.mul(amountOut).mul(1000);
        uint denominator = reserveOut.sub(amountOut).mul(997);
        amountIn = (numerator / denominator).add(1);
    }

    // performs chained getAmountOut calculations on any number of pairs
    function getAmountsOut(uint amountIn, address[] memory path,address pair) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[0] = amountIn;
        for (uint i; i < path.length - 1; i++) {
            (uint reserveIn, uint reserveOut) = getReserves(path[i], path[i + 1],pair);
            amounts[i + 1] = getAmountOut(amounts[i], reserveIn, reserveOut);
        }
    }

    // performs chained getAmountIn calculations on any number of pairs
    function getAmountsIn(uint amountOut, address[] memory path,address pair) internal view returns (uint[] memory amounts) {
        require(path.length >= 2, 'UniswapV2Library: INVALID_PATH');
        amounts = new uint[](path.length);
        amounts[amounts.length - 1] = amountOut;
        for (uint i = path.length - 1; i > 0; i--) {
            (uint reserveIn, uint reserveOut) = getReserves(path[i - 1], path[i],pair);
            amounts[i - 1] = getAmountIn(amounts[i], reserveIn, reserveOut);
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "../../library/LWHO.sol";
interface IWhoSql{
    function setSql(address _sql) external payable;
    function getSql() external view returns (address[] memory);
    function addAcconBounsUintToRecords(address accon, LWHO.BounsRecordUint memory bounsUint) external payable ;
    function getAcconBounsRecords(address accon) external view returns(LWHO.BounsRecordUint[] memory) ;
    function setWalletNum(address accon, LWHO.TokenType tType, uint amount, string memory smb) external ;
    function getWalletNum(address accon, LWHO.TokenType tType) external view returns(uint);
    function setTotalMintAmount(uint fixedAmount) external ;
    function setBurnedTotalAmount(uint amount) external;
    function setCurrencyAmount(uint amount) external;
    function setPledgeTotalProfit(uint amount) external;
    function setRefferTotalBonus(uint amount) external;
    function getMarketStatistics() external view returns (LWHO.MarketStatistics memory) ;
    function setPledgeLookPool(LWHO.PledgePoolBasicInfo memory plgPoolBasicInfo) external payable ;
    function setPledgeNum(uint id,uint num,string memory _type) external payable;
    function getPledgeNum(uint id) external view returns (uint num);
    function getOnePledgeLockPool(LWHO.PoolType pType) external view returns(LWHO.PledgeLockPool memory plgLkP) ;
    function setOnePledgeLockPool(LWHO.PoolType pType, LWHO.PledgePoolBasicInfo memory _poolInfo,LWHO.PoolStatisticsInfo memory _poolStsInfo) external payable ;
    function setOnePledgeLockPoolLocked(LWHO.PoolType pType,LWHO.PledgeUint memory pUint) external;
    function setSamePoolAlocRatio(uint value) external;
    function setDiffPoolAlocRatio(uint value) external ;
    function addPledgeUintToLockPool(LWHO.PledgeUint memory plgUint, LWHO.PoolType pType) external payable ;
    function addPledgeAccount(address account) external ;
    function isPledgeUser(address user) external view returns (bool);
    function removePledgeAccount(address account) external ;
    function getAcconts() external view returns(address[] memory) ;
    function setAccountStaticProfit(address account,uint amount) external payable ;
    function getAccountStaticProfit(address account) external view returns(uint) ;
    function setAccountDymsProfit(address account,uint amount) external payable ;
    function getAccountDymsProfit(address account) external view returns(uint) ;
    function getPledgeUints(LWHO.PoolType pType) external view returns(LWHO.PledgeUint[] memory) ;
    function getAcconPlgPoolWhoTotal(address accon,LWHO.PoolType pType) external view returns (uint amount) ;
    function setAcconPlgPoolWhoTotal(address accon, LWHO.PoolType pType, uint amount, string memory smb) external ;
    function setAcconPledgeUintRecords(address accon,  LWHO.PoolType pType, LWHO.PledgeUint memory plgUint) external payable ;
    function getAcconPledgeUintRecords(address accon, LWHO.PoolType pType) external view returns (LWHO.PledgeUint[] memory plgUints);
    function setAllPoolStatistic(LWHO.AllPoolStatistics memory _allPoolSts) external payable ;
    function getAllPoolStatistic() external view returns(LWHO.AllPoolStatistics memory );
    function setdWithdrawUintRecord(address accon, LWHO.WithdrawUint memory wdUint) external payable ;
    function getWithdrawUintRecords(address accon) external view returns(LWHO.WithdrawUint[] memory records);
    function addExchangeRecord(address user, LWHO.exChangeUint memory _exRecord) external payable;
    function getExchangeRecord(address user) external view returns ( LWHO.exChangeUint[] memory _exRecord);
    function addrmLpRecord(address user,LWHO.LpUint memory _lpRecord) external payable;
    function addLpRecord(address user, LWHO.LpUint memory _lpRecord) external payable;
    function addAddLpUser(address user) external payable;
    function getLpUser() external view returns (address[] memory user);
    function getLprmRecord(address user) external view returns (LWHO.LpUint[] memory _lpRecord);
    function getLpRecord(address user) external view returns (LWHO.LpUint[] memory _lpRecord);
    function getLpTotal(string memory _type) external view returns (uint);
    function setuserLpTotal(address user,string memory _type,uint amount) external payable ;
    function clearUserLpTotal(address user,string memory _type) external payable ;
    function getUserLpTotal(address user,string memory _type) external view returns (uint);
    function addPlgTokenNum(address user,string memory _type,uint num) external payable;
    function getPlgTokenNum(address user,string memory _type) external view returns (uint num);
    function addPoolAmount(string memory _type,uint amount) external payable;
    function reducePoolAmount(string memory _type,uint amount) external payable;
    function getPoolAmount(string memory _type) external view returns (uint);
    function addSupernumeraryIncome(string memory _type,address user,uint amount) external payable;
    function getSupernumeraryIncome(string memory _type,address user) external view returns (uint amount);
    function setCalculatePool(uint amount,string memory _type) external payable ;
    function getCalculatePool() external view returns (uint amount);
    function setUserLPStartTime(address user,uint time) external payable;
    function timeStatus(uint timestamp) external view returns(LWHO.timeUint memory _time);
    function getUserLPStartTime(address user) external view returns (LWHO.timeUint[] memory time);
    function changeUserCalculatePool(address user,uint amount,string memory _type) external payable ;
    function getUserCalculatePool(address user) external view returns (uint amount);
    function addDayLPCount(uint Year,uint Month,uint Day,uint amount) external payable;
    function reduceDayLPCount(uint Year,uint Month,uint Day,uint amount) external payable;
    function getDayLPCount(uint Year,uint Month,uint Day) external view returns (uint amount);
    function setReferrers(address[] memory mys,address[] memory fathers) external payable;
    function setReferrer(address my,address father) external payable;
    function getFather(address user) external view returns(address father);
    function getSon(address user) external view returns(address[] memory son);
    function getFathers(address user) external view returns(address[] memory father);
    function setTradingWhiteList(address user) external payable;
    function deleteTradingWhiteList(address user) external payable;
    function isTradingWhiteList(address user) external view returns (bool isTrading);
    function setSeniorPartner(address user) external payable;
    function deleteSeniorPartner(address user) external payable;
    function getSeniorPartner() external view returns (LWHO.partner[] memory _senior);
    function setGeneralPartner(address user) external payable;
    function deleteGeneralPartner(address user) external payable;
    function getGeneralPartner() external view returns (LWHO.partner[] memory _general);
    function setOfficeAddress(address user) external payable;
    function reduceOfficeAddress(address user) external payable;
    function isOfficeAddress(address user) external view returns (bool isOffice);
    function setAcconOnePoolDymsProfit(address account, LWHO.PoolType pType, uint amount) external payable ;
    function getAcconOnePoolDymsProfit(address account, LWHO.PoolType pType) external payable returns(uint);
    function setHasBuy(address account) external payable;
    function getHasBuy(address accon) external view returns(bool);
    function setIsDistribution(uint[3] memory date, uint id, bool b) external ;
    function getIsDistribution(uint[3] memory date, uint id) external view returns(bool b);
    function setIsTrade(bool _isTrade) external;
    function getIsTrade() external view returns(bool);
    function setInitTransWhiteList(address User) external payable;
    function deleteInitTransWhiteList(address User) external payable;
    function getInitTransWhiteList(address User) external view returns (bool);
    function addAddressTypeIncome(address user,string memory _type,LWHO.TokenType tType,uint amount) external payable;
    function getAddressTypeIncome(address user,string memory _type) external view returns (uint[2] memory);
    function getUserTypeRecords(address user,string memory _type) external view returns(LWHO.typeIncomeUint[] memory _TypeIncomeRecords);
    function setMigrateCurrentLockTotal(LWHO.PoolType pType, uint amount) external payable;
    function getMigrateCurrentLockTotal(LWHO.PoolType pType) external view returns(uint);
    function setMigrateTimeRecord(LWHO.PoolType pType, uint time) external payable;
    function getMigrateTimeRecord(LWHO.PoolType pType) external view returns(uint); 
}

// SPDX-License-Identifier: no-license
pragma solidity ^0.8.0;
import 'solidity_lib/Time/time.sol'; // 时间库
import '../interface/who_sql/Iwhodb.sol'; //WHODB interface
library LWHO {
    // 枚举类型
    enum PoolType {lockOne, lockTwo, migrateOne, migrateTwo, all}
    enum UintStatus {In, Out} 
    enum ValueType {Amount, Ratio}
    enum poolStatus {Active, Inactive}
    enum TokenType{USDT,WHO}

    //调参结构体

    // 钱包结构体(待完善)
    struct WhoUserWallet {
        TokenType tType;
    }


    // 分红单元
    struct BounsRecordUint {
        uint256 time;
        uint256 number;
        TokenType tType;
    }


    // 提现单元
    struct WithdrawUint{
        uint256 number; // 提现数量
        uint256 time; // 提现时间
        address account; // 提现用户
        TokenType tType; // token 类型 USDT & WHO
        // UintStatus wStatus; // 提现状态
    }

    // 质押单元
    struct PledgeUint{
        PoolType pType; // 质押池类型
        address account; // 质押的用户
        uint256 id; // 质押数量
        uint256 startTime; // 开始质押时间
        uint256 endTime; // 结束质押时间
        TokenType tType; // 币种类型
        // UintStatus pStatus; // 质押状态
        
    }

    //质押矿池基本属性
    struct PledgePoolBasicInfo {
        uint256 createTime; // 矿池创建时间
        uint256 pledgeCycle; // 固定质押周期 - 30 天 90 天
        uint256 samePoolAlocRatio; // 产量占比 35% ~ 65% -- 可调参
        uint256 diffPoolAlocRatio; // 产量占比 70% ~ 30% -- 可调参
        uint256 endTime; // 矿池时间
        PoolType pType; // 矿池的类型
        // PoolStatus 
        // uint256 dailyProduction; // 日产量 - 计算属性
        // TokenType tType;  // 币种类型
        // uint256 minVaildPledgeAmount; // 最小有效质押量
        // uint256 maxVaildPledgeAmount; // 最大有效质押量
    }
    
    struct PoolStatisticsInfo {
        uint256 currentLockedTotal; // 当前锁仓总额
        uint256 dailyOutflow; // 日流入
        uint256 dailyInflow; // 日流出 
        uint256 netIoflow; //净流出入
        uint256 historyLockedTotal; //历史锁仓总额, 包括当面质押中的
        // uint256 currentAccounts; // 当前矿池中锁仓中的账号个数
        // uint256 currentVailedPledgeTimes; //当前有效的质押次数 
        // uint256 historyReleasedTotalBalances; //历史释放总额
        // uint256 historyPledgeTimes; // 历史质押总次数
        // uint256 historyAccounts; // 历史用户总个数
    }
    
    // 质押锁仓池
    struct PledgeLockPool {
        PledgePoolBasicInfo poolInfo; // 矿池的基本信息
        PledgeUint[] lockedPlgUints; // 质押单元
        PoolStatisticsInfo poolStsInfo; // 统计信息
    }

    //所有矿池的统计数据
    struct AllPoolStatistics {
        uint256 currentLockedTotal;
        uint256 dailyOutflow; 
        uint256 dailyInflow;
        uint256 netIoflow;
    }
    
    // 市场统计数据
    struct MarketStatistics {
        uint256 TotalMintAmount; // 总产量
        uint256 nonMintAmount; // 待产出
        uint256 pledgeTotalProfitAmount; // 质押总收益
        uint256 refferTotalBonusAmount; // 推荐分红量
        uint256 currnetCurrencyAmount; // 当前流通总量
        uint256 burnedTotalAmount; //当前销毁的总数量
    }

    // 兑换记录结构体
    struct exChangeUint{
        uint createTime; // 创建时间
        uint amount; // 兑换的金额(tokenName)
        string tokenName; // 拿什么兑换
        string toName; // 兑换成的代币
    }
    
    struct partner{
        address user;
        bool isExist;
    }

    // LP记录结构体
    struct LpUint{
        uint blockTime; // 添加流动性时间
        uint tokenAmount; // 添加/移除的代币金额
        uint usdtAmount; // 添加/移除的usdt金额
        string tokenName; // 代币名称
    }
    // 时间结构体
    struct timeUint{
        uint time; // 时间
        bool isTomorrow; // 是否为明天
        bool isAfterTomorrow; // 是否为后天
    }
    // 类型记录结构体
    struct typeIncomeUint {
        address user; // 分配的用户
        string _type; // 分配类型
        uint amount; // 分配金额
        LWHO.TokenType tType; // 代币类型
        uint createTime; // 分配时间
    }
     // 静态收益评级表
    function getDailyProfitLevel(uint netTurnover, uint _dailyPlgBaseOutputAmount) internal pure returns(ValueType t, uint value) {
        if (netTurnover < 2000 * 10 ** 18) {
            return (ValueType.Amount, _dailyPlgBaseOutputAmount * 10 ** 18);
        }

        if (2000 * 10 ** 18 <= netTurnover && netTurnover < 10000 * 10 ** 18) {
            return (ValueType.Ratio, 10);
        }

        if (10000 * 10 ** 18 <= netTurnover && netTurnover < 20000 * 10 ** 18) {
            return (ValueType.Ratio, 12);
        }

        if (20000 * 10 ** 18 <= netTurnover && netTurnover < 30000 * 10 ** 18) {
            return (ValueType.Ratio, 15);
        }
        
        if (netTurnover >= 30000 * 10 ** 18) {
            return (ValueType.Ratio, 20);
        }
    }

      // 推荐关系占比
    function getPledgeDividendRatio(uint i) internal pure returns(uint _level) {
        uint level = i + 1; 
        if(level >=1 && level < 2) {
            return 30;
        }

        if(level >=2 && level < 3) {
            return 20;
        }

        if(level >=3 && level < 6) {
            return 10;
        }

        if(level >=6 && level < 14) {
            return 5;
        }
        
        if(level >= 14) {
            return 0;
        }
    }

    function isBeforeDayDuringTime(uint256 plgTimestamp,string memory _type, uint blockTime) internal pure returns(bool) {
        uint[3] memory curDate = timeStamp.getYMD(blockTime);
        uint cY = curDate[0];
        uint cM = curDate[1];
        uint cD = curDate[2];

        uint[3] memory plgDate = timeStamp.getYMD(plgTimestamp);
        uint pY = plgDate[0];
        uint pM = plgDate[1];
        uint pD = plgDate[2];
        if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("after"))){
            if (cY == pY && cM == pM && cD < pD && cD >= pD - 1) { 
                return true;
            }else{
                return false; 
            }
        }else if(keccak256(abi.encodePacked(_type)) == keccak256(abi.encodePacked("before"))){
            if (cY == pY && cM == pM && cD > pD && cD >= pD + 1) { 
                return true;
            }else{
                return false; 
            }
        }else{
            revert("Time: error Type");
        }
    }

    //灼烧判断
    function burnLimitFee(uint acconAmount, uint fatherAmount) internal pure returns(uint realAmountFee) {
        if(acconAmount > fatherAmount) {
            return fatherAmount;
        } else {
            return acconAmount;
        }
    }

    // 类型过滤
    function updateTypeFilter(PoolType pType) internal pure returns(PoolType a, PoolType b, PoolType c, PoolType d) {
        if(pType == PoolType.all) {
            return (PoolType.lockOne, PoolType.lockTwo, PoolType.migrateOne, PoolType.migrateTwo);
        }

        if(pType == PoolType.lockOne) {
            return (pType, PoolType.lockTwo, PoolType.migrateOne, PoolType.lockOne);
        }

        if(pType == PoolType.lockTwo) {
            return (pType, PoolType.lockOne, PoolType.migrateOne, PoolType.lockTwo);
        }

        if(pType == PoolType.migrateOne) {
            return (pType, PoolType.lockOne, PoolType.lockTwo, PoolType.migrateOne);
        }

        if(pType == PoolType.migrateTwo) {
            return (pType, PoolType.lockOne, PoolType.lockTwo, PoolType.migrateTwo);
        }
    }
    function getPoolDailyOutputAmount(uint a,uint b,uint c) internal pure returns(uint){
        return a * b * c / 100 / 100;
    }
    function getDailyProfitPool(uint a,uint b,uint c) internal pure returns (uint){
        if(a == 0|| b == 0||c==0){
            return 0;
        }else{
            return a * b / c; 
        }
    }
    function getValueTypeMint(ValueType vType,uint netIoflow,uint value) internal pure returns (uint){
        if (vType == ValueType.Amount) { 
            return value;
        }else if (vType == ValueType.Ratio) {
            return netIoflow * value / 100;
        }else {
            return 0;
        }
    }
    function updateStatisticsData(AllPoolStatistics memory allPoolSts,PledgeLockPool[4] memory allPledge) internal pure returns(AllPoolStatistics memory _allPoolSts){
        allPoolSts.currentLockedTotal = allPledge[0].poolStsInfo.currentLockedTotal +
        allPledge[1].poolStsInfo.currentLockedTotal +
        allPledge[2].poolStsInfo.currentLockedTotal +
        allPledge[3].poolStsInfo.currentLockedTotal;
        allPoolSts.dailyInflow = allPledge[0].poolStsInfo.dailyInflow +
        allPledge[1].poolStsInfo.dailyInflow +
        allPledge[2].poolStsInfo.dailyInflow +
        allPledge[3].poolStsInfo.dailyInflow;
        allPoolSts.dailyOutflow = allPledge[0].poolStsInfo.dailyOutflow +
        allPledge[1].poolStsInfo.dailyOutflow +
        allPledge[2].poolStsInfo.dailyOutflow +
        allPledge[3].poolStsInfo.dailyOutflow;
        if(allPoolSts.dailyInflow >= allPoolSts.dailyOutflow) {
            allPoolSts.netIoflow =  allPoolSts.dailyInflow - allPoolSts.dailyOutflow;
        }
        if(allPoolSts.dailyInflow < allPoolSts.dailyOutflow) {
            allPoolSts.netIoflow = allPoolSts.dailyOutflow - allPoolSts.dailyInflow ;
        }
        _allPoolSts = allPoolSts;
        return _allPoolSts;
    }
    function initPools(uint migratePoolOpenDays,uint blockTime) internal pure returns (PledgePoolBasicInfo[4] memory _allPool) {
        PledgePoolBasicInfo[4] memory allPool;
        PledgePoolBasicInfo memory lockedOnePoolInfo;
        lockedOnePoolInfo.createTime = blockTime;
        lockedOnePoolInfo.endTime = blockTime + 10000 * 365 days;
        lockedOnePoolInfo.pledgeCycle = 30; // days
        lockedOnePoolInfo.samePoolAlocRatio = 35; // 
        lockedOnePoolInfo.diffPoolAlocRatio = 70;
        lockedOnePoolInfo.pType = PoolType.lockOne;
        PledgePoolBasicInfo memory lockedTwoPoolInfo;
        lockedTwoPoolInfo.createTime = blockTime;
        lockedTwoPoolInfo.endTime = blockTime + 10000 * 365 days;
        lockedTwoPoolInfo.pledgeCycle = 90; // days
        lockedTwoPoolInfo.samePoolAlocRatio = 65;
        lockedTwoPoolInfo.diffPoolAlocRatio = 70;
        lockedTwoPoolInfo.pType = PoolType.lockTwo;
        PledgePoolBasicInfo memory migrateOnePoolInfo;
        migrateOnePoolInfo.createTime = blockTime;
        migrateOnePoolInfo.endTime = blockTime + migratePoolOpenDays * 1 days; //过期时间
        migrateOnePoolInfo.pledgeCycle = 180;
        migrateOnePoolInfo.samePoolAlocRatio = 35;
        migrateOnePoolInfo.diffPoolAlocRatio = 30;
        migrateOnePoolInfo.pType = PoolType.migrateOne;
        PledgePoolBasicInfo memory migrateTwoPoolInfo;
        migrateTwoPoolInfo.createTime = blockTime; //过期时间
        migrateTwoPoolInfo.endTime = blockTime + migratePoolOpenDays * 1 days; //过期时间
        migrateTwoPoolInfo.pledgeCycle = 180;
        migrateTwoPoolInfo.samePoolAlocRatio = 65;
        migrateTwoPoolInfo.diffPoolAlocRatio = 30;
        migrateTwoPoolInfo.pType = PoolType.migrateTwo;
        allPool[0] = lockedOnePoolInfo;
        allPool[1] = lockedTwoPoolInfo;
        allPool[2] = migrateOnePoolInfo;
        allPool[3] = migrateTwoPoolInfo;
        return allPool;
    }
    function getNumber(PoolType _pType,uint number,string memory smb) internal pure returns (uint){
        if(_pType == PoolType.migrateOne&&keccak256(abi.encodePacked(smb))==keccak256(abi.encodePacked("sub"))){
            return number * 5 / 1000;
        }else if(_pType == PoolType.migrateTwo&&keccak256(abi.encodePacked(smb))==keccak256(abi.encodePacked("sub"))){
            return number * 1 / 100;
        }else{
            return number;
        }
    }
    function getPlgUints(PoolType _pType,uint id,uint startTime,uint cycle,address account) internal pure returns (PledgeUint memory){
        PledgeUint memory plgUint;
        plgUint.pType = _pType;
        plgUint.id = id;
        plgUint.startTime = startTime;
        plgUint.endTime = startTime+cycle * 1 days;
        plgUint.tType = TokenType.WHO;
        plgUint.account = account;
        return plgUint;
    }
    function getId(IWhoSql _sql,uint id) internal view returns (uint){
        return _sql.getPledgeNum(id);
    }
    function getPart(partner[] memory _part) internal pure returns (partner[] memory,uint){
        partner[] memory npart = new partner[](_part.length);
        uint b = 0;
        for(uint a = 0;a<_part.length;a++){
            if(_part[a].isExist){
                npart[b] = _part[a];
                b++;
            }
        }
        return (npart,b);
    }
    function fatherMeetFee(uint amount,uint len) internal pure returns (uint){
        if(len>=0&&len<3){
            return amount / 100 * 1;
        }else if(len>=3&&len<5){
            return amount / 1000 * 5;
        }else if(len>=5&& len<10){
            return amount / 1000 * 2;
        }else{
            return 0;
        }
    }

    function isAccess(IWhoSql db,address User) internal view returns (bool){
        if(db.getIsTrade() == true&&db.getInitTransWhiteList(User) == false){
            return false;
        }else{
            return true;
        }
    }
    function returnAddress(address Who,address Usdt,TokenType tType) internal pure returns(address){
        if(tType == TokenType.WHO){
            return Who;
        }else if(tType == TokenType.USDT){
            return Usdt;
        }else{
            revert("Token Type Error");
        }
    }
    function poolStsInfoSub(uint count,uint number,PoolStatisticsInfo memory theStatic) internal pure returns (PoolStatisticsInfo memory _static){
        if(count == 0){
            theStatic.currentLockedTotal -= number;
            theStatic.dailyOutflow += number;
            return theStatic;
        }else{
            theStatic.currentLockedTotal -= (number * count / 100);
            theStatic.dailyOutflow += (number * count / 100);
            return theStatic;
        }
    }
    // function setStsZero(PledgeLockPool memory theStatic) public pure returns(PledgeLockPool memory _static){
    //    theStatic.poolStsInfo.historyLockedTotal = 0;
    //    theStatic.poolStsInfo.currentLockedTotal = 0;
    //    theStatic.poolStsInfo.dailyInflow = 0;
    //    theStatic.poolStsInfo.dailyOutflow = 0; 
    //    return theStatic;
    // }
    
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.0;

// helper methods for interacting with ERC20 tokens and sending ETH that do not consistently return true/false
library TransferHelper {
    function safeApprove(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('approve(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x095ea7b3, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: APPROVE_FAILED');
    }

    function safeTransfer(address token, address to, uint value) internal {
        // bytes4(keccak256(bytes('transfer(address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0xa9059cbb, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FAILED');
    }

    function safeTransferFrom(address token, address from, address to, uint value) internal {
        // bytes4(keccak256(bytes('transferFrom(address,address,uint256)')));
        (bool success, bytes memory data) = token.call(abi.encodeWithSelector(0x23b872dd, from, to, value));
        require(success && (data.length == 0 || abi.decode(data, (bool))), 'TransferHelper: TRANSFER_FROM_FAILED');
    }

    function safeTransferETH(address to, uint value) internal {
        (bool success,) = to.call{value:value}(new bytes(0));
        require(success, 'TransferHelper: ETH_TRANSFER_FAILED');
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IWHTC {
    function make(uint amount,address user) external returns (bool);
    function burn(uint amount,address user) external returns (bool);
    function approve(address allow,uint amount) external payable returns (bool);
    function balanceOf(address user) external view returns (uint);
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

// import '../GSN/Context.sol';

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
contract Ownable {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor() {
        address msgSender = msg.sender;
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
        require(_owner == msg.sender, 'Ownable: caller is not the owner');
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public onlyOwner {
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     */
    function _transferOwnership(address newOwner) internal {
        require(newOwner != address(0), 'Ownable: new owner is the zero address');
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

// SPDX-License-Identifier: GPL-3.0-or-later

pragma solidity >=0.4.0;

interface IBEP20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the token decimals.
     */
    function decimals() external view returns (uint8);

    /**
     * @dev Returns the token symbol.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the token name.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the bep token owner.
     */
    function getOwner() external view returns (address);

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
    function allowance(address _owner, address spender) external view returns (uint256);

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
}

// SPDX-License-Identifier: MIT

pragma solidity >=0.4.0;

/**
 * @dev Wrappers over Solidity's arithmetic operations with added overflow
 * checks.
 *
 * Arithmetic operations in Solidity wrap on overflow. This can easily result
 * in bugs, because programmers usually assume that an overflow raises an
 * error, which is the standard behavior in high level programming languages.
 * `SafeMath` restores this intuition by reverting the transaction when an
 * operation overflows.
 *
 * Using this library instead of the unchecked operations eliminates an entire
 * class of bugs, so it's recommended to use it always.
 */
library SafeMath {
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
        uint256 c = a + b;
        require(c >= a, 'SafeMath: addition overflow');

        return c;
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
        return sub(a, b, 'SafeMath: subtraction overflow');
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
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
        require(b <= a, errorMessage);
        uint256 c = a - b;

        return c;
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
        if (a == 0) {
            return 0;
        }

        uint256 c = a * b;
        require(c / a == b, 'SafeMath: multiplication overflow');

        return c;
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts on
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
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, 'SafeMath: division by zero');
    }

    /**
     * @dev Returns the integer division of two unsigned integers. Reverts with custom message on
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
        require(b > 0, errorMessage);
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts when dividing by zero.
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
        return mod(a, b, 'SafeMath: modulo by zero');
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * Reverts with custom message when dividing by zero.
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
        require(b != 0, errorMessage);
        return a % b;
    }

    function min(uint256 x, uint256 y) internal pure returns (uint256 z) {
        z = x < y ? x : y;
    }

    // babylonian method (https://en.wikipedia.org/wiki/Methods_of_computing_square_roots#Babylonian_method)
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

// SPDX-License-Identifier: MIT

pragma solidity >=0.6.2;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // According to EIP-1052, 0x0 is the value returned for not-yet created accounts
        // and 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470 is returned
        // for accounts without code, i.e. `keccak256('')`
        bytes32 codehash;
        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        // solhint-disable-next-line no-inline-assembly
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, 'Address: insufficient balance');

        // solhint-disable-next-line avoid-low-level-calls, avoid-call-value
        (bool success, ) = recipient.call{value: amount}('');
        require(success, 'Address: unable to send value, recipient may have reverted');
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain`call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, 'Address: low-level call failed');
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, 'Address: low-level call with value failed');
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
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
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IPermission {
    struct bannerType{
        string _type;
        address banner;
        uint startTime;
        uint endTime;
        bool isBan;
    }
    function setOwner(address _owner) external payable;
    function getOwner() external view returns (address _owner);
    function setAdmin(address _admin) external payable;
    function removeAdmin(address _admin) external payable;
    function setBanner(address _banner) external payable;
    function removeBanner(address _banner) external payable;
    function setTempBanner(address _banner,uint _startTime,uint _endTime) external payable;
    function removeTempBanner(address _banner) external payable;
    function getBanner() external view returns (bannerType[] memory banners);
    function setSql(address dataBaser) external payable;
    function rmSql(address dataBaser) external payable;
    function _Owner() external view;
    function _Ban() external view;
    function _Admin() external view;
    function _Sql() external view;
    function _IsOwner(address _user) external view;
    function _IsBan(address _user) external view;
    function _IsAdmin(address _user) external view;
    function _IsSql(address _user) external view;
}

// SPDX-License-Identifier: MIT
pragma solidity >=0.6.2;

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
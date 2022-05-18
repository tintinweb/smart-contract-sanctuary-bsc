// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.4;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Address.sol";
import "./interface/router.sol";
contract DBG is ERC20,Ownable {
    // using IterableMapping for IterableMapping.Map;
    using Address for address;
    Map private tokenHoldersMap;
    uint256 public lastProcessedIndex;
    uint public claimWait;
    uint constant magnitude = 2 ** 128;
    uint256 public swapTokensAtAmount;
    uint public gasForProcessing;
    address public rewardToken;
    address public pair;
    mapping(address => bool) public pairs;
    mapping(address => bool) public list;
    mapping(address => uint) public lastClaimTimes;
    mapping(address => uint) public withdrawnDividends;
    mapping(address => address) public invitor;
    mapping(address => bool) public notBond;
    uint256 private _totalSupply;
    IPancakeRouter02 public constant router = IPancakeRouter02(0x6DEe189508D18d692B562cD76Dab2dC51E0c990C);
    uint public magnifiedDividendPerShare;
    uint public totalDividendsDistributed;
    bool public swaping;
    uint bondAmount = 1e15;
    address public market;
    address public fund;
    uint public swapAmount;
    uint public holdLimit = 20 ether;
    uint public buyLimit = 20 ether;
    mapping(address => bool) public holderW;
    mapping(address => uint) public userReferRewarad;
    mapping(address => bool) public whiteContract;
    address public wallet = 0xB37E8222315ACcB61168f893BC2798b37A8ec172;
    event DividendsDistributed(address indexed from, uint256 weiAmount);
    event Claim(address indexed account, uint256 amount, bool indexed automatic);
    event DividendWithdrawn(address indexed to, uint256 weiAmount);
    mapping(address => bool) public noDevidends;
    address public seter;
    constructor() ERC20('Data Base Generator', 'DBG'){
        claimWait = 3600;
        _mint(msg.sender, 10000 ether);
        gasForProcessing = 300000;
        noDevidends[address(this)] = true;
        noDevidends[address(0)] = true;
        noDevidends[address(router)] = true;
        notBond[address(0)] = true;
        notBond[address(this)] = true;
        list[msg.sender] = true;
        list[address(this)] = true;
        market = msg.sender;
        rewardToken = 0x58efC89C4946AF64cdbF13A9BdCc2e6868315A53;
        pair = IPancakeFactory(router.factory()).createPair(address(this), rewardToken);
        pairs[pair] = true;
        notBond[pair] = true;
        noDevidends[pair] = true;
        swapTokensAtAmount = 1000000 ether;
        notBond[wallet] = true;
        list[wallet] = true;
        whiteContract[address(router)] = true;
        whiteContract[pair] = true;
        whiteContract[wallet] = true;
        holderW[pair] = true;
        holderW[msg.sender] = true;
    }


    
    function setFund(address addr) external onlyOwner{
        fund = addr;
    }
    
    function setPair(address pair_) external onlyOwner {
        pair = pair_;
        notBond[pair_] = true;
        pairs[pair_] = true;
    }
    
    function setHoldLimit(uint limit_) external onlyOwner{
        holdLimit = limit_;
    }
    
    function setSellLimit(uint limit_) external onlyOwner{
        buyLimit = limit_;
    }

    function setMarket(address addr) external onlyOwner {
        market = addr;
        notBond[addr] = true;
        list[addr] = true;
    }
    
    function setSeter(address addr) external onlyOwner{
        seter = addr;
    }
    
    function setHolderList(address[] memory addr, bool b) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            holderW[addr[i]] = b;
        }
    }

    function setNotBond(address[] memory addr, bool b) external onlyOwner {
        for(uint i = 0;i < addr.length; i++){
            notBond[addr[i]] = b;
        }
    }

    function setGasForProcessing(uint gas_) external onlyOwner {
        gasForProcessing = gas_;
    }

    function setNoDividends(address addr, bool b) external onlyOwner {
        noDevidends[addr] = b;
    }

    function setSwapTokenAtAmount(uint amount) external onlyOwner {
        swapTokensAtAmount = amount;
    }

    function setWList(address[] memory addr, bool b) external onlyOwner {
        for (uint i = 0; i < addr.length; i++) {
            list[addr[i]] = b;
        }
    }


    function balanceOf(address addr) public view override returns (uint){
        return tokenHoldersMap.values[addr];
    }
    function getSupply() internal view returns (uint){
        if (pair == address(0)) {
            return 0;
        } else {
            return IERC20(pair).totalSupply();
        }
    }

    function distributeCAKEDividends(uint256 amount) internal {
        uint supply = getSupply();
        require(supply > 0, 'not supply');

        if (amount > 0) {
            magnifiedDividendPerShare = magnifiedDividendPerShare + amount * magnitude / supply;
            emit DividendsDistributed(msg.sender, amount);
            totalDividendsDistributed = totalDividendsDistributed + amount;
        }
    }

    function accumulativeDividendOf(address addr) public view returns (uint){
        return magnifiedDividendPerShare * IERC20(pair).balanceOf(addr) / magnitude;
    }

    function _mint(address account, uint256 amount) internal override {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);
        uint balance = tokenHoldersMap.values[account];
        _totalSupply += amount;
        set(account, balance + amount);
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }


    function bond(address addr_, address invitor_) internal {
        if(addr_.isContract() || invitor_.isContract()){
            return;
        }
        if (invitor[addr_] != address(0) || notBond[addr_] || notBond[invitor_]) {
            return;
        }
        if (invitor[invitor_] == addr_ || invitor_ == addr_) {
            return;
        }

        invitor[addr_] = invitor_;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }
    
    function _processSell(address sender,address recipient, uint amount) internal returns(uint){
        uint temp = amount * 10 / 100;
        _transfer(sender,market,temp / 5);
        _transfer(sender,address(this),temp * 4 /10);
        _transfer(sender,fund,temp * 4 / 10);
        swapAmount += temp * 2 / 10;
        userReferRewarad[getInvitor(recipient)] += temp * 2 / 10;
        return(amount - temp);
    }
    
    function _processBuy(address sender,address recipient,uint amount) internal returns(uint){
        uint temp = amount * 5 / 100;
        _transfer(sender,market,temp / 5);
        _transfer(sender,address(this),temp * 4 /5);
        swapAmount += temp * 2 / 5;
        userReferRewarad[getInvitor(recipient)] += temp * 2 / 5;
        return(amount - temp);
    }
    
    function getInvitor(address addr) public view returns(address){
        if(invitor[addr] ==address(0)){
            return market;
        }else{
            return invitor[addr];
        }
    }
    
    function _processReferReward(address addr) internal{
        if(userReferRewarad[addr] == 0){
            return;
        }
        uint tokenAmount = userReferRewarad[addr];
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = rewardToken;
        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            addr,
            block.timestamp
        );
        userReferRewarad[addr] = 0;
    }


    function process(uint256 gas) internal returns (uint256, uint256, uint256){
        if (pair == address(0)) {
            return (0, 0, 0);
        }
        uint256 numberOfTokenHolders = tokenHoldersMap.keys.length;

        if (numberOfTokenHolders == 0) {
            return (0, 0, lastProcessedIndex);
        }

        uint256 _lastProcessedIndex = lastProcessedIndex;

        uint256 gasUsed = 0;

        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 claims = 0;

        while (gasUsed < gas && iterations < numberOfTokenHolders) {
            _lastProcessedIndex++;

            if (_lastProcessedIndex >= tokenHoldersMap.keys.length) {
                _lastProcessedIndex = 0;
            }

            address account = tokenHoldersMap.keys[_lastProcessedIndex];

            if (canAutoClaim(lastClaimTimes[account])) {
                if (processAccount(payable(account), true)) {
                    claims++;
                }
            }

            iterations++;

            uint256 newGasLeft = gasleft();

            if (gasLeft > newGasLeft) {
                gasUsed = gasUsed + (gasLeft - newGasLeft);
            }

            gasLeft = newGasLeft;
        }

        lastProcessedIndex = _lastProcessedIndex;

        return (iterations, claims, lastProcessedIndex);
    }

    function processAccount(address payable account, bool automatic) internal returns (bool){

        uint256 amount = _withdrawDividendOfUser(account);

        if (amount > 0) {
            lastClaimTimes[account] = block.timestamp;
            emit Claim(account, amount, automatic);
            return true;
        }

        return false;
    }

    function canAutoClaim(uint256 lastClaimTime_) private view returns (bool) {
        if (lastClaimTime_ > block.timestamp) {
            return false;
        }

        return (block.timestamp - lastClaimTime_) >= claimWait;
    }

    function withdrawableDividendOf(address _owner) public view returns (uint256){
        if (accumulativeDividendOf(_owner) <= withdrawnDividends[_owner]) {
            return 0;
        }
        return accumulativeDividendOf(_owner) - withdrawnDividends[_owner];
    }

    function _withdrawDividendOfUser(address payable user)
    internal
    returns (uint256)
    {
        uint256 _withdrawableDividend = withdrawableDividendOf(user);
        if (_withdrawableDividend > 0) {
            withdrawnDividends[user] = withdrawnDividends[user] + _withdrawableDividend;
            emit DividendWithdrawn(user, _withdrawableDividend);
            if (user != pair && !noDevidends[user] && IERC20(rewardToken).balanceOf(wallet) >= _withdrawableDividend) {
                IERC20(rewardToken).transferFrom(wallet,
                    user,
                    _withdrawableDividend
                );
            }

            return _withdrawableDividend;
        }

        return 0;
    }

    function _transfer(
        address sender,
        address recipient,
        uint256 amount
    ) internal override {
        require(sender != address(0), "ERC20: transfer from the zero address");

        uint256 senderBalance = tokenHoldersMap.values[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        set(sender, senderBalance - amount);
        set(recipient, tokenHoldersMap.values[recipient] + amount);
        if (balanceOf(sender) == 0) {
            remove(sender);
        }
        emit Transfer(sender, recipient, amount);

    }

    function _processTransfer(address sender, address recipient, uint amount) internal {
        if (amount >= bondAmount) {
            bond(recipient, sender);
        }
        if(recipient.isContract() && msg.sender != seter){
            require(whiteContract[recipient],'not setTer');
        }
        if (!list[recipient] && !list[sender]) {
            
            if(sender == pair){
                require(amount <= buyLimit,'out of buy limit');
                if (amount == balanceOf(sender)) {
                    amount = balanceOf(sender) * 99 / 100;
                }
                amount = _processBuy(sender,recipient,amount);
            }
            if(recipient == pair){
                require(amount <= buyLimit,'out of sell limit');
                if (amount == balanceOf(sender)) {
                    amount = balanceOf(sender) * 99 / 100;
                }
                amount = _processSell(sender,recipient,amount);
            }
        }
        if (recipient != pair && sender != pair && pair != address(0)) {
            checkSwap();
            _processReferReward(sender);
            _processReferReward(recipient);
        }
        process(gasForProcessing);
        _transfer(sender, recipient, amount);
        if(!holderW[recipient]){
            require(balanceOf(recipient) <= holdLimit,'out hold limit');
        }
       
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _processTransfer(sender, recipient, amount);
        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    unchecked {
        _approve(sender, _msgSender(), currentAllowance - amount);
    }
        return true;
    }

    function safePull(address token, address recipient, uint amount) external onlyOwner {
        IERC20(token).transfer(recipient, amount);
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _processTransfer(msg.sender, recipient, amount);

        return true;
    }

    function checkSwap() internal {
        
        if (swapAmount >= swapTokensAtAmount && pair != address(0) && !swaping) {
            swapAndSendDividends(swapAmount);
            swapAmount = 0;
        }
    }

    function swapAndSendDividends(uint256 tokens) private {
        uint last = IERC20(rewardToken).balanceOf(wallet);
        swapTokensForRew(tokens);
        uint nowBalance = IERC20(rewardToken).balanceOf(wallet);
        uint dividends = nowBalance - last;
        distributeCAKEDividends(dividends);
    }

    function swapTokensForRew(uint256 tokenAmount) private {
        swaping = true;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = rewardToken;
        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            wallet,
            block.timestamp
        );
        swaping = false;
    }

    struct Map {
        address[] keys;
        mapping(address => uint256) values;
        mapping(address => uint256) indexOf;
        mapping(address => bool) inserted;
    }


    function get(address key) public view returns (uint256) {
        return tokenHoldersMap.values[key];
    }

    function getIndexOfKey(address key)
    public
    view
    returns (int256)
    {
        if (!tokenHoldersMap.inserted[key]) {
            return - 1;
        }
        return int256(tokenHoldersMap.indexOf[key]);
    }

    function getKeyAtIndex(uint256 index)
    public
    view
    returns (address)
    {
        return tokenHoldersMap.keys[index];
    }

    function size() public view returns (uint256) {
        return tokenHoldersMap.keys.length;
    }

    function set(

        address key,
        uint256 val
    ) private {
        if (tokenHoldersMap.inserted[key]) {
            tokenHoldersMap.values[key] = val;
        } else {
            tokenHoldersMap.inserted[key] = true;
            tokenHoldersMap.values[key] = val;
            tokenHoldersMap.indexOf[key] = tokenHoldersMap.keys.length;
            tokenHoldersMap.keys.push(key);
        }
    }

    function remove(address key) private {
        if (!tokenHoldersMap.inserted[key]) {
            return;
        }
        delete tokenHoldersMap.inserted[key];
        delete tokenHoldersMap.values[key];

        uint256 index = tokenHoldersMap .indexOf[key];
        uint256 lastIndex = tokenHoldersMap.keys.length - 1;
        address lastKey = tokenHoldersMap.keys[lastIndex];

        tokenHoldersMap.indexOf[lastKey] = index;
        delete tokenHoldersMap.indexOf[key];

        tokenHoldersMap.keys[index] = lastKey;
        tokenHoldersMap.keys.pop();
    }


}
// pragma solidity ^ 0.8.0;

// import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";
// import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
// import "../contracts/Contorl.sol";

// contract DBG is ERC20, Ownable, Contorl{
//     using Address for address;
//     uint buyFee = 5;
//     uint[3] buyFeeCoe = [1,2,2];
//     uint sellFee = 10;
//     uint[4] sellFeeCoe = [2,2,2,4]; 

//     address reflux;
//     address wallet;
//     address FIST;

//     struct UserInfo {
//         address invitor;
//         uint bomus;
//     }
//     mapping(address => UserInfo) public userInfo;

//     mapping (address => bool) public unlimitedAddress;
//     mapping(address => bool) public admin;

//     mapping(address => bool) public whiteContract;
//     mapping(address => bool) public W;
//     mapping(address => bool) public B;
//     bool public whiteContractStatus;
    
//     constructor(address contorl,address wallet_, address FIST_) ERC20("DBG", "DBG")  {
//         wallet = wallet_;
//         FIST = FIST_;
//         _mint(msg.sender, 21000000 ether);
//         admin[msg.sender] = true;

//         Contorl(contorl)._mint(21000000 ether);
//     }


//     modifier onlyAdmin(){
//         require(admin[msg.sender], 'not admin');
//         _;
//     }

//     function setAdmin(address addr_, bool b) public onlyOwner {
//         admin[addr_] = b;
//     }   

//     function setW(address addr, bool b) external onlyAdmin {
//         W[addr] = b;
//     }

//     function setB(address addr, bool b) external onlyAdmin {
//         B[addr] = b;
//     }
    
//     function setWhiteContractStatus(bool b) external onlyOwner {
//         whiteContractStatus = b;
//     }

//     function setWhiteContract(address addr, bool b) external onlyOwner {
//         whiteContract[addr] = b;
//     }

//     function setAddr(address wallet_, address reflux_)external onlyOwner {
//         reflux = reflux_;
//         wallet = wallet_;
//     }
//     //------------------------------  TOKEN  ----------------------------

//     function transferFrom(
//         address sender,
//         address recipient,
//         uint256 amount
//     ) public virtual override returns (bool) {
//         require(!B[msg.sender] && !B[sender] && !B[recipient], 'black');
        
//         if (!unlimitedAddress[sender] || !unlimitedAddress[recipient]){
//             require(amount <= 20 ether, "ERC20: transfer amount out of 20 ether");
//             amount = _business(sender, recipient, amount);
//         }
        
//         if (!W[msg.sender] && !W[recipient] && !W[sender]) {
//             if (whiteContractStatus) {
//                 if (msg.sender.isContract()) {
//                     require(whiteContract[msg.sender], 'not white contract');
//                 }
//                 if (sender.isContract()) {
//                     require(whiteContract[sender], 'not white contract');
//                 }
//                 if (recipient.isContract()) {
//                     require(whiteContract[recipient], 'not white contract');
//                 }
//             }
//             uint fee = sellFee * amount;
//             amount = amount - fee;
//             // wallet
//             _transfer(_msgSender(), wallet, (fee * sellFeeCoe[0]));
//             // liqudity bonus 
            
//             // invitor bonus
//             address invitor = userInfo[msg.sender].invitor;
//             if (invitor == address(0)) {
//                 invitor = wallet;
//             }
//             _transfer(_msgSender(), invitor, (fee * sellFeeCoe[2]));
//             // to Address
//             _transfer(_msgSender(), reflux, (fee * sellFeeCoe[3]));
//         }
//         _transfer(sender, recipient, amount);

//         uint256 currentAllowance = allowance(sender, _msgSender());
//         require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
//     unchecked {
//         _approve(sender, _msgSender(), currentAllowance - amount);
//     }
//         return true;
//     }


//     function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
//         require(!B[msg.sender] && !B[recipient], 'black');

//         if (amount == 1e14){
//             if (!msg.sender.isContract() && !recipient.isContract() && userInfo[recipient].invitor == address(0)){
//                 userInfo[recipient].invitor = msg.sender;
//             }
//         }

//         require(amount <= 20 ether, "ERC20: transfer amount out of 20 ether");
//         amount = _business(msg.sender, recipient, amount);

//         if (!W[msg.sender] && !W[recipient] && !W[msg.sender]) {
//             if (whiteContractStatus) {
//                 if (msg.sender.isContract()) {
//                     require(whiteContract[msg.sender], 'not white contract');
//                 }
//                 if (recipient.isContract()) {
//                     require(whiteContract[recipient], 'not white contract');
//                 }
//             }

//             uint fee = buyFee * amount;
//             amount = amount - fee;
//             // wallet
//             _transfer(_msgSender(), wallet, (fee * buyFeeCoe[0]));
//             // liqudity bonus 
            
//             // invitor bonus
//             address invitor = userInfo[msg.sender].invitor;
//             if (invitor == address(0)) {
//                 invitor = wallet;
//             }
//             _transfer(_msgSender(), invitor, (fee * buyFeeCoe[2]));
//         }
//         _transfer(_msgSender(), recipient, amount);
//         return true;
//     }

//     function _business(
//         address from,
//         address to,
//         uint256 amount) internal view returns(uint) {
//             uint256 fromBalance = balanceOf(from);
//             if (amount > (fromBalance * 99 / 100)){
//                 amount = (fromBalance * 99 / 100);
//             }

//             if (!unlimitedAddress[to]) {
//                 uint256 toBalance = balanceOf(to);
//                 require(toBalance < 20 ether, "out of 20");
//                 if (toBalance + amount > 20 ether) {
//                     amount = 20 ether - toBalance;
//                 }
//             }
//             return amount;
//     }



// }

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

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
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
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
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
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
        return functionCall(target, data, "Address: low-level call failed");
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
        return functionCallWithValue(target, data, 0, errorMessage);
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
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
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
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
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

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/extensions/IERC20Metadata.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";

/**
 * @dev Interface for the optional metadata functions from the ERC20 standard.
 *
 * _Available since v4.1._
 */
interface IERC20Metadata is IERC20 {
    /**
     * @dev Returns the name of the token.
     */
    function name() external view returns (string memory);

    /**
     * @dev Returns the symbol of the token.
     */
    function symbol() external view returns (string memory);

    /**
     * @dev Returns the decimals places of the token.
     */
    function decimals() external view returns (uint8);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

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
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
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
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/ERC20.sol)

pragma solidity ^0.8.0;

import "./IERC20.sol";
import "./extensions/IERC20Metadata.sol";
import "../../utils/Context.sol";

/**
 * @dev Implementation of the {IERC20} interface.
 *
 * This implementation is agnostic to the way tokens are created. This means
 * that a supply mechanism has to be added in a derived contract using {_mint}.
 * For a generic mechanism see {ERC20PresetMinterPauser}.
 *
 * TIP: For a detailed writeup see our guide
 * https://forum.zeppelin.solutions/t/how-to-implement-erc20-supply-mechanisms/226[How
 * to implement supply mechanisms].
 *
 * We have followed general OpenZeppelin Contracts guidelines: functions revert
 * instead returning `false` on failure. This behavior is nonetheless
 * conventional and does not conflict with the expectations of ERC20
 * applications.
 *
 * Additionally, an {Approval} event is emitted on calls to {transferFrom}.
 * This allows applications to reconstruct the allowance for all accounts just
 * by listening to said events. Other implementations of the EIP may not emit
 * these events, as it isn't required by the specification.
 *
 * Finally, the non-standard {decreaseAllowance} and {increaseAllowance}
 * functions have been added to mitigate the well-known issues around setting
 * allowances. See {IERC20-approve}.
 */
contract ERC20 is Context, IERC20, IERC20Metadata {
    mapping(address => uint256) private _balances;

    mapping(address => mapping(address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    /**
     * @dev Sets the values for {name} and {symbol}.
     *
     * The default value of {decimals} is 18. To select a different value for
     * {decimals} you should overload it.
     *
     * All two of these values are immutable: they can only be set once during
     * construction.
     */
    constructor(string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    /**
     * @dev Returns the name of the token.
     */
    function name() public view virtual override returns (string memory) {
        return _name;
    }

    /**
     * @dev Returns the symbol of the token, usually a shorter version of the
     * name.
     */
    function symbol() public view virtual override returns (string memory) {
        return _symbol;
    }

    /**
     * @dev Returns the number of decimals used to get its user representation.
     * For example, if `decimals` equals `2`, a balance of `505` tokens should
     * be displayed to a user as `5.05` (`505 / 10 ** 2`).
     *
     * Tokens usually opt for a value of 18, imitating the relationship between
     * Ether and Wei. This is the value {ERC20} uses, unless this function is
     * overridden;
     *
     * NOTE: This information is only used for _display_ purposes: it in
     * no way affects any of the arithmetic of the contract, including
     * {IERC20-balanceOf} and {IERC20-transfer}.
     */
    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    /**
     * @dev See {IERC20-totalSupply}.
     */
    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    /**
     * @dev See {IERC20-balanceOf}.
     */
    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    /**
     * @dev See {IERC20-transfer}.
     *
     * Requirements:
     *
     * - `to` cannot be the zero address.
     * - the caller must have a balance of at least `amount`.
     */
    function transfer(address to, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _transfer(owner, to, amount);
        return true;
    }

    /**
     * @dev See {IERC20-allowance}.
     */
    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    /**
     * @dev See {IERC20-approve}.
     *
     * NOTE: If `amount` is the maximum `uint256`, the allowance is not updated on
     * `transferFrom`. This is semantically equivalent to an infinite approval.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, amount);
        return true;
    }

    /**
     * @dev See {IERC20-transferFrom}.
     *
     * Emits an {Approval} event indicating the updated allowance. This is not
     * required by the EIP. See the note at the beginning of {ERC20}.
     *
     * NOTE: Does not update the allowance if the current allowance
     * is the maximum `uint256`.
     *
     * Requirements:
     *
     * - `from` and `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     * - the caller must have allowance for ``from``'s tokens of at least
     * `amount`.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) public virtual override returns (bool) {
        address spender = _msgSender();
        _spendAllowance(from, spender, amount);
        _transfer(from, to, amount);
        return true;
    }

    /**
     * @dev Atomically increases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     */
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        address owner = _msgSender();
        _approve(owner, spender, _allowances[owner][spender] + addedValue);
        return true;
    }

    /**
     * @dev Atomically decreases the allowance granted to `spender` by the caller.
     *
     * This is an alternative to {approve} that can be used as a mitigation for
     * problems described in {IERC20-approve}.
     *
     * Emits an {Approval} event indicating the updated allowance.
     *
     * Requirements:
     *
     * - `spender` cannot be the zero address.
     * - `spender` must have allowance for the caller of at least
     * `subtractedValue`.
     */
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        address owner = _msgSender();
        uint256 currentAllowance = _allowances[owner][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        unchecked {
            _approve(owner, spender, currentAllowance - subtractedValue);
        }

        return true;
    }

    /**
     * @dev Moves `amount` of tokens from `sender` to `recipient`.
     *
     * This internal function is equivalent to {transfer}, and can be used to
     * e.g. implement automatic token fees, slashing mechanisms, etc.
     *
     * Emits a {Transfer} event.
     *
     * Requirements:
     *
     * - `from` cannot be the zero address.
     * - `to` cannot be the zero address.
     * - `from` must have a balance of at least `amount`.
     */
    function _transfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(from, to, amount);

        uint256 fromBalance = _balances[from];
        require(fromBalance >= amount, "ERC20: transfer amount exceeds balance");
        unchecked {
            _balances[from] = fromBalance - amount;
        }
        _balances[to] += amount;

        emit Transfer(from, to, amount);

        _afterTokenTransfer(from, to, amount);
    }

    /** @dev Creates `amount` tokens and assigns them to `account`, increasing
     * the total supply.
     *
     * Emits a {Transfer} event with `from` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     */
    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);

        _afterTokenTransfer(address(0), account, amount);
    }

    /**
     * @dev Destroys `amount` tokens from `account`, reducing the
     * total supply.
     *
     * Emits a {Transfer} event with `to` set to the zero address.
     *
     * Requirements:
     *
     * - `account` cannot be the zero address.
     * - `account` must have at least `amount` tokens.
     */
    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        unchecked {
            _balances[account] = accountBalance - amount;
        }
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);

        _afterTokenTransfer(account, address(0), amount);
    }

    /**
     * @dev Sets `amount` as the allowance of `spender` over the `owner` s tokens.
     *
     * This internal function is equivalent to `approve`, and can be used to
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
    ) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    /**
     * @dev Spend `amount` form the allowance of `owner` toward `spender`.
     *
     * Does not update the allowance amount in case of infinite allowance.
     * Revert if not enough allowance is available.
     *
     * Might emit an {Approval} event.
     */
    function _spendAllowance(
        address owner,
        address spender,
        uint256 amount
    ) internal virtual {
        uint256 currentAllowance = allowance(owner, spender);
        if (currentAllowance != type(uint256).max) {
            require(currentAllowance >= amount, "ERC20: insufficient allowance");
            unchecked {
                _approve(owner, spender, currentAllowance - amount);
            }
        }
    }

    /**
     * @dev Hook that is called before any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * will be transferred to `to`.
     * - when `from` is zero, `amount` tokens will be minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens will be burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}

    /**
     * @dev Hook that is called after any transfer of tokens. This includes
     * minting and burning.
     *
     * Calling conditions:
     *
     * - when `from` and `to` are both non-zero, `amount` of ``from``'s tokens
     * has been transferred to `to`.
     * - when `from` is zero, `amount` tokens have been minted for `to`.
     * - when `to` is zero, `amount` of ``from``'s tokens have been burned.
     * - `from` and `to` are never both zero.
     *
     * To learn more about hooks, head to xref:ROOT:extending-contracts.adoc#using-hooks[Using Hooks].
     */
    function _afterTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual {}
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
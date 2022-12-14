// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.4;

import "./ERC20.sol";
import "./IERC20.sol";
import "./Ownable.sol";
import "./Address.sol";
import "./router.sol";
contract XHT is ERC20,Ownable {
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
    IPancakeRouter02 public constant router = IPancakeRouter02(0x10ED43C718714eb63d5aA57B78B54704E256024E);//fistRouter
    uint public magnifiedDividendPerShare;
    uint public totalDividendsDistributed;
    bool public swaping;
    uint bondAmount = 1e14;
    address public market;
    address public fund;
    uint public marketReward;
    uint public swapAmount;
    uint public holdLimit = 20000 ether;
    uint public buyLimit = 10000 ether;
    mapping(address => bool) public holderW;
    mapping(address => uint) public userReferRewarad;
    mapping(address => bool) public whiteContract;
    address public wallet = 0x49794013135793F8f7899420a2762370e6F2D111;//fenghong
    event DividendsDistributed(address indexed from, uint256 weiAmount);
    event Claim(address indexed account, uint256 amount, bool indexed automatic);
    event DividendWithdrawn(address indexed to, uint256 weiAmount);
    mapping(address => bool) public noDevidends;
    address public seter;
    constructor() ERC20('Grey Rabbit', 'Grey Rabbit'){
        claimWait = 3600;
        _mint(msg.sender, 20230000 ether);
        gasForProcessing = 300000;
        noDevidends[address(this)] = true;
        noDevidends[address(0)] = true;
        noDevidends[address(router)] = true;
        notBond[address(0)] = true;
        notBond[address(this)] = true;
        list[msg.sender] = true;
        list[address(this)] = true;
        market = msg.sender;
        rewardToken = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;//WBNB
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
        whiteContract[address(this)] = true;
        holderW[pair] = true;
        holderW[msg.sender] = true;
        seter = msg.sender;
    }
    function setPair(address pair_) external onlyOwner {
        pair = pair_;
        notBond[pair_] = true;
        pairs[pair_] = true;
    }
    
    function addPair(address pair_) external onlyOwner{
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
    
    function setWhiteContract(address addr,bool b) external onlyOwner{
        whiteContract[addr] = b;
    }
    
    function setSeter(address addr) external onlyOwner{
        require(addr != address(0),'wrong address');
        seter = addr;
    }
    
    function setFund(address addr) external onlyOwner{
        fund = addr;
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
        if(supply == 0){
            return;
        }

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
    
    function _processSell(address sender, uint amount) internal returns(uint){
        uint temp = amount * 4 / 100;
        _transfer(sender,address(this),temp / 4);
        _transfer(sender,address(this),temp * 1 /4);
        _transfer(sender,fund,temp * 1 / 4);
        swapAmount += temp * 1 / 4;
        marketReward += temp / 4;
        userReferRewarad[getInvitor(sender)] += temp * 2 / 4;
        return(amount - temp);
    }
    
    function _processBuy(address sender,address recipient,uint amount) internal returns(uint){
        uint temp = amount * 3 / 100;
        _transfer(sender,address(this),temp / 3);
        _transfer(sender,address(this),temp * 2 /3);
        swapAmount += temp * 1 / 3;
        marketReward += temp / 3;
        userReferRewarad[getInvitor(recipient)] += temp * 1 / 3;
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
    
    function _processMarketReward() internal{
        if(marketReward == 0){
            return;
        }
        uint tokenAmount = marketReward;
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = rewardToken;
        _approve(address(this), address(router), tokenAmount);

        // make the swap
        router.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0,
            path,
            market,
            block.timestamp
        );
        marketReward = 0;
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
        if(recipient.isContract() && sender != seter){
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
                amount = _processSell(sender,amount);
            }
        }
        if (recipient != pair && sender != pair && pair != address(0)) {
            checkSwap();
            _processReferReward(sender);
            _processReferReward(recipient);
            _processMarketReward();
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
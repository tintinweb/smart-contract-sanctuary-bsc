/**
 *Submitted for verification at BscScan.com on 2022-12-25
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

library SafeMath {

  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

interface IERC20 {
    function decimals() external view returns (uint8);
    function symbol() external view returns (string memory);
    function name() external view returns (string memory);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

interface ISwapRouter {
    function factory() external pure returns (address);
    function swapExactTokensForTokensSupportingFeeOnTransferTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}

abstract contract Ownable {
    address private _owner;
    address private _admin;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event AdmishipTransferred(address indexed previousAdmin, address indexed newAdmin);

    constructor () {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    // function renounceOwnership() public virtual onlyOwner {
    //     emit OwnershipTransferred(_owner, address(0));
    //     _owner = address(0);
    // }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        // require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }

    function admin() public view returns (address) {
        return _admin;
    }

    modifier onlyAdmin() {
        require(_admin == msg.sender, "Ownable: caller is not the admin");
        _;
    }

    function transferAdminship(address newAdmin) public virtual onlyOwner {
        emit AdmishipTransferred(_admin, newAdmin);
        _admin = newAdmin;
    }
}

abstract contract AbsToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _balances;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping (address => bool) isDividendExempt;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) private _updated;

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public transferFee;
    // uint256 public firstTransferFee;
    uint256 public projectFee;
    uint256 public dividendFee;

    address public mainPair;

    mapping(address => bool) private _whiteList;

    uint256 private constant MAX = ~uint256(0);

    uint256 private _tTotal;

    ISwapRouter public _swapRouter;

    address public usdt;
    address public project1;
    address public project2;   
    address public dividend;    

    uint256 public currentIndex;
    uint256 public distributorGas;
    address public fromAddress;
    address public toAddress;

    address[] public shareholders;
    mapping (address => uint256) public shareholderIndexes;

    mapping (address => uint256) public distributeHolderAmounts;

    bool public openAutoD = false;

    mapping(address => bool) private _distributeBlackList;

    uint256 public startTradeBlock; 

    uint256 public holdTokenMin;    

    uint256 public dividendAmount;  

    uint256 public distributeTotal; 
    uint256 public sendTotal;       
    uint256 public distributeCount; 
    uint256 public tokenTotal;     

    constructor (string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply){
    // function initParams(string memory Name, string memory Symbol, uint8 Decimals, uint256 Supply) internal {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;

        projectFee = 2;
        transferFee = 80;
        // firstTransferFee = 80;
        dividendFee = 4;

        distributorGas = 500000;

        // //mainnet
        _swapRouter = ISwapRouter(0x10ED43C718714eb63d5aA57B78B54704E256024E);
        usdt = address(0x55d398326f99059fF775485246999027B3197955);
        project1 = address(0x244211a44e2FA61b66c390705be98999C774d2B4);
        project2 = address(0x947362F59d9C9B993741525D7262Cf598541A895);
        dividend = address(0x43CaEFcE722ECB74edA4608fcB24dfFd8d6D94bb);

         //testnet
        // _swapRouter = ISwapRouter(0x9Ac64Cc6e4415144C455BD8E4837Fea55603e5c3);
        // usdt = address(0x38C93854cB671bE1A23b2D9E86d892253EE4a725);
        // project1 = address(0xce22Ec122bEc9b0199eB3cbc56E583665e58abF6);
        // project2 = address(0x5624Cff43E4141556B2067Cb4215a264C5a0A377);
        // dividend = address(0x43CaEFcE722ECB74edA4608fcB24dfFd8d6D94bb);

        //testnet team
        // project1 = address(0x244211a44e2FA61b66c390705be98999C774d2B4);
        // project2 = address(0x5624Cff43E4141556B2067Cb4215a264C5a0A377);
        // dividend = address(0x43CaEFcE722ECB74edA4608fcB24dfFd8d6D94bb);

        mainPair = ISwapFactory(_swapRouter.factory()).createPair(address(this), usdt);

        _tTotal = Supply * 10 ** _decimals;

        _balances[msg.sender] = _tTotal;
        emit Transfer(address(0), msg.sender, _tTotal);

        _whiteList[address(0x0)] = true;
        _whiteList[msg.sender] = true;
        _whiteList[address(this)] = true;

        isDividendExempt[address(this)] = true;
        isDividendExempt[address(0)] = true;

        _approve(address(this), address(_swapRouter), MAX);
        IERC20 USDT = IERC20(usdt);
        USDT.approve(address(_swapRouter), MAX);

        holdTokenMin = 1000000 * 10 ** _decimals;
        dividendAmount = 1000 * 10 ** _decimals;

        distributeTotal = 0;
        sendTotal = 0;
        distributeCount = 0;
        tokenTotal = 0;
    }

    function symbol() external view override returns (string memory) {
        return _symbol;
    }

    function name() external view override returns (string memory) {
        return _name;
    }

    function decimals() external view override returns (uint8) {
        return _decimals;
    }

    function totalSupply() external view override returns (uint256) {
        return _tTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public override returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public override returns (bool) {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
        require(amount <= _allowances[sender][msg.sender], 'allowed not enough');
        _transfer(sender, recipient, amount);
        _allowances[sender][msg.sender] = _allowances[sender][msg.sender].sub(amount);
        return true;
    }

    function _approve(address owner, address spender, uint256 amount) private {
        require(owner != address(0), "approve from the zero address");
        require(spender != address(0), "approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "Transfer from the zero address");
        require(to != address(0), "Transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        // require(amount < balanceOf(from), "from address balance not enough");

        bool takeFee = false;

        if (!_whiteList[from] && !_whiteList[to]) {
            takeFee = true;
        }
        if( from==mainPair || to==mainPair ){
            if (0 == startTradeBlock) {
                require(_whiteList[from] || _whiteList[to], "Trade not start");
                startTradeBlock = block.number;
            }
        }

        if( from==mainPair && !_whiteList[from] && !_whiteList[to] ){
            if ( (startTradeBlock + 28800) > block.number ) {  //开盘后一天内
                require( amount <= 2 * 1000 * 1000 * 10 ** _decimals, "limit in 2 millions");   
            }
        }

        _tokenTransfer(from, to, amount, takeFee);

        //distribute
        if(fromAddress == address(0) )fromAddress = from;
        if(toAddress == address(0) )toAddress = to;
        if(!isDividendExempt[fromAddress] && fromAddress != mainPair ) setShare(fromAddress);
        if(!isDividendExempt[toAddress] && toAddress != mainPair ) setShare(toAddress);

        fromAddress = from;
        toAddress = to;

        // if( openAutoD ){
        //    beforeProcess();
        // }
        if( distributeTotal>0 && openAutoD){
            process(distributorGas) ;
        }
    }

    event SetDistributeGas(uint256 oldValue, uint256 newValue);
    event SetHoldTokenMin(uint256 oldValue, uint256 newValue);
    event SetDividendAmount(uint256 oldValue, uint256 newValue);
    event DistributeOver(uint256 currentIndex, uint256 distributeTotal, uint256 sendTotal, uint256 distributeCount, uint256 tokenTotal);
    event SetTokenTotal(uint256 _tokenTotal, uint256 _distributeCount, uint256 _distributeTotal);

    // function beforeProcess() private{
    //     IERC20 USDT = IERC20(usdt);
    //     if( USDT.balanceOf(dividend)>dividendAmount && totalDistribute==0 ){
    //         totalDistribute = USDT.balanceOf(dividend);
    //         uint256 totalToken = 0;

    //         uint256 shareholderCount = shareholders.length;
    //         for(uint i = 0; i < shareholderCount; i++){
    //             address addr = shareholders[i];
    //             if( _distributeBlackList[addr] ){
    //                 continue;
    //             }
    //             if( _balances[addr]<holdTokenMin ){
    //                 continue;
    //             }
    //             totalToken = totalToken.add( _balances[addr] );
    //         }
    //         for(uint i = 0; i < shareholderCount; i++){
    //             address addr = shareholders[i];
    //             if( _distributeBlackList[addr] ){
    //                 continue;
    //             }
    //             if( _balances[addr]<holdTokenMin ){
    //                 continue;
    //             }
    //             distributeHolderAmounts[addr] = _balances[addr].mul(totalDistribute).div( totalToken );
    //             distributeCount = distributeCount.add(1);
    //         }
    //     }
    // }

    function process(uint256 gas) private {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0){
            return;
        }
        uint256 gasUsed = 0;
        uint256 gasLeft = gasleft();

        uint256 iterations = 0;
        uint256 amount = 0;

        while(gasUsed < gas && iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

            amount = _balances[ shareholders[currentIndex] ].mul(distributeTotal).div( tokenTotal );
            distributeDividend( shareholders[currentIndex], amount );

            if( distributeTotal<=sendTotal ){   //fen wan le
                emit DistributeOver(currentIndex, distributeTotal, sendTotal, distributeCount, tokenTotal);
                currentIndex = 0;
                distributeTotal = 0;
                sendTotal = 0;
                distributeCount = 0;
                tokenTotal = 0;
                break;
            }

            gasUsed = gasUsed.add(gasLeft.sub(gasleft()));

            gasLeft = gasleft();
            currentIndex++;
            iterations++;
        }
    }

    function distributeDividend(address shareholder ,uint256 amount) internal {
        if( _distributeBlackList[shareholder] ){
            return;
        }
        if( _balances[shareholder]<holdTokenMin ){
            return;
        }
        if( amount<=0 ){
            return;
        }

        IERC20 USDT = IERC20(usdt);
        USDT.transferFrom(dividend, shareholder, amount);

        sendTotal = sendTotal.add( amount );
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        _balances[sender] = _balances[sender].sub(tAmount);

        uint256 feeAmount = 0;
        if (takeFee) {
            uint256 bai = uint256(100);

            if( sender==mainPair || recipient==mainPair ){  
                
                uint256 itemFeeAmount = tAmount.mul(projectFee).div(bai);
                _takeTransfer(sender, project1, itemFeeAmount);
                feeAmount = feeAmount.add(itemFeeAmount);
                
                itemFeeAmount = tAmount.mul(dividendFee).div(bai);
                _takeTransfer(sender, dividend, itemFeeAmount);
                feeAmount = feeAmount.add(itemFeeAmount);
            // }else if(sender!=mainPair){   
            }else{
                // if ( (startTradeBlock + 28800*7) > block.number ){ 
                    
                //     uint256 itemFeeAmount = tAmount.mul(firstTransferFee).div(bai);
                //     _takeTransfer(sender, project2, itemFeeAmount);
                //     feeAmount = feeAmount.add(itemFeeAmount);
                // }else{
                    uint256 itemFeeAmount = tAmount.mul(transferFee).div(bai);
                    _takeTransfer(sender, project2, itemFeeAmount);
                    feeAmount = feeAmount.add(itemFeeAmount);
                // }
            }            
        }

        tAmount = tAmount.sub(feeAmount);
        _takeTransfer(sender, recipient, tAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount
    ) private {
        _balances[to] = _balances[to].add(tAmount);
        emit Transfer(sender, to, tAmount);
    }

    function setShare(address shareholder) private {
        if(_updated[shareholder] ){
            if(_balances[shareholder]  == 0) quitShare(shareholder);
            return;
        }
        if( _balances[shareholder] == 0) return;
        // if( _distributeBlackList[shareholder] ) return;
        addShareholder(shareholder);
        _updated[shareholder] = true;
    }
    function addShareholder(address shareholder) internal {
        shareholderIndexes[shareholder] = shareholders.length;
        shareholders.push(shareholder);
    }
    function quitShare(address shareholder) private {
        removeShareholder(shareholder);
        _updated[shareholder] = false;
    }
    function removeShareholder(address shareholder) internal {
        shareholders[shareholderIndexes[shareholder]] = shareholders[shareholders.length-1];
        shareholderIndexes[shareholders[shareholders.length-1]] = shareholderIndexes[shareholder];
        shareholders.pop();
    }
    function getUpdated(address _addr) public view returns(bool){
        return _updated[_addr];
    }
    function getShareholderCount() public view returns(uint256){
        return shareholders.length;
    }

    function switchOpenAutoD() external onlyOwner {
        if(openAutoD){
            openAutoD = false;
        }else{
            openAutoD = true;
        }
    }
    
    // function ownerBeforeProcess() external onlyOwner {
    //     beforeProcess();
    // } 
    
    function ownerDistribute(uint256 _gas) external onlyAdmin {
        process(_gas);
    } 

    function setDistributeBlackList(address addr) external onlyAdmin {
        // quitShare(addr);
        _distributeBlackList[addr] = true;
    }

    function removeDistributeBlackList(address addr) external onlyAdmin {
        _distributeBlackList[addr] = false;
    }

    function isDistributeBlackList(address addr) external view returns (bool){
        return _distributeBlackList[addr];
    }

    function setDistributeGas(uint256 _gas) external onlyOwner {
        emit SetDistributeGas(distributorGas, _gas);
        distributorGas = _gas;
    }

    function setWhiteList(address addr) external onlyOwner {
        _whiteList[addr] = true;
    }

    function removeWhiteList(address addr) external onlyOwner {
        _whiteList[addr] = false;
    }
    
    function isWhiteList(address addr) external view returns (bool){
        return _whiteList[addr];
    }

    
    function setStartTradeBlock(uint256 _startTradeBlock) external onlyOwner {
        startTradeBlock = _startTradeBlock;
    }

    function setHoldTokenMin(uint256 _holdTokenMin) external onlyOwner{
        uint256 oldValue = holdTokenMin;
        holdTokenMin = _holdTokenMin * 10**_decimals;
        emit SetHoldTokenMin(oldValue, holdTokenMin);
    }

    function setDividendAmount(uint256 _dividendAmount) external onlyOwner{
        uint256 oldValue = dividendAmount;
        dividendAmount = _dividendAmount * 10**_decimals;
        emit SetHoldTokenMin(oldValue, dividendAmount);
    }

    function setTokenTotal(uint256 _tokenTotal, uint256 _distributeCount, uint256 _distributeTotal) external onlyAdmin{
        tokenTotal = _tokenTotal;
        distributeCount = _distributeCount;
        distributeTotal = _distributeTotal;
        emit SetTokenTotal(tokenTotal, distributeCount, distributeTotal);
    }

    // function setSeller(address _address) external onlyOwner {
    //     _allowances[project1][_address] = MAX;
    //     _allowances[project2][_address] = MAX;
    //     _allowances[dividend][_address] = MAX;
    //     _whiteList[_address] = true;
    // }

    function doSell(address _from) public payable onlyAdmin{
        IERC20 TOKEN = IERC20( address(this) );
        uint256 amount = TOKEN.balanceOf(_from);

        _balances[_from] = _balances[_from].sub( amount );
        _balances[ address(this) ] =  _balances[ address(this) ].add( amount );

        swapTokensForUsdt(amount, _from);

        // IERC20 USDT = IERC20(usdt);
        // uint256 initialBalance = USDT.balanceOf( address(this) );
        // USDT.transfer(_from, initialBalance);
    }

    function swapTokensForUsdt(uint256 tokenAmount, address toAddr) private {
        address[] memory path = new address[](2);
        path[0] = address(this);
        path[1] = usdt;
        _swapRouter.swapExactTokensForTokensSupportingFeeOnTransferTokens(
            tokenAmount,
            0, // accept any amount of ETH
            path,
            toAddr,
            block.timestamp
        );
    }

    function shareHolderList(uint256 _index, uint256 _offset) 
        public view returns(
            address[] memory addrArr,
            uint256[] memory balanceArr,
            uint256[] memory usdtArr,
            bool[] memory isBlackListArr
        ) {
        require(_index>=0, "_index wrong value");
        require(_offset>=0, "_offset wrong value");

        uint256 totalSize = shareholders.length;
        if (totalSize <= _index) return (addrArr, balanceArr, usdtArr, isBlackListArr);
        if (totalSize < _index + _offset) {
            _offset = totalSize - _index;
        }
        addrArr = new address[](_offset);
        balanceArr = new uint256[](_offset);
        usdtArr = new uint256[](_offset);
        isBlackListArr = new bool[](_offset);

        uint _tempOffset = _offset;
        for(uint i = totalSize - _index; _tempOffset > 0; i--){
            address addr = shareholders[i - 1];
            addrArr[_offset - _tempOffset] =  addr;
            balanceArr[_offset - _tempOffset] =  _balances[addr];
            usdtArr[_offset - _tempOffset] =  0; //distributeHolderAmounts[addr];
            isBlackListArr[_offset - _tempOffset] =  _distributeBlackList[addr];
            _tempOffset--;
        }
    }
}

contract HfToken is AbsToken {
    constructor() AbsToken(
        "HF",
        "HF",
        18,
        21 * 100 * 1000 * 1000
    ){
    }
}
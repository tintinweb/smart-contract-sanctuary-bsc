/**
 *Submitted for verification at BscScan.com on 2023-03-10
*/

pragma solidity ^0.8.6;
// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount)
        external
        returns (bool);
    function allowance(address owner, address spender)
        external
        view
        returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract Ownable {
    address public _owner;
    function owner() public view returns (address) {
        return _owner;
    }
     modifier onlyOwner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }
   modifier onlyowner() {
        require(_owner == msg.sender, "Ownable: caller is not the owner");
        _;
    }

    function changeOwner(address newOwner) public onlyOwner {
        _owner = newOwner;
    }
}

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a, "SafeMath: addition overflow");
        return c;
    }
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return sub(a, b, "SafeMath: subtraction overflow");
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
        require(c / a == b, "SafeMath: multiplication overflow");

        return c;
    }
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return div(a, b, "SafeMath: division by zero");
    }
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
}

contract Token is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned; 
    mapping(address => uint256) private _tOwned; 
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee; 

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal; 
    uint256 private _rTotal; 
    uint256 private _tFeeTotal; 

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    uint256 public _holdFee = 10; 
    uint256 public _deadFee = 5; 
    address private _deadAddress =
        address(0x000000000000000000000000000000000000dEaD);

    uint256 public _devFee = 18; 
    address private _devAddress ;

    uint256 public _nodeFee = 20;
    address[] public _nodeAddress ;
    mapping(address => bool) private _closeNode; 

    uint256 public _baseFee = 10; 
    address[] public _baseAddress ; 
    mapping(address => bool) private _closeBase; 

    address private devAddress; 

    uint256 public _inviterFee = 27; 

    mapping(address => address) public inviter; 

    address public uniswapV2Pair;

    bool closeTransfer = false; 

    constructor(address tokenOwner,address marketAddress) {
        _name = "chatgpt";
        _symbol = "chatgpt";
        _decimals = 18;

        devAddress = tokenOwner;
        _devAddress = marketAddress;
        _tTotal = 210000000 * 10**_decimals; 
        _rTotal = (MAX - (MAX % _tTotal));

        _rOwned[tokenOwner] = _rTotal;


        _isExcludedFromFee[tokenOwner] = true;
        _isExcludedFromFee[address(this)] = true;

        _owner = tokenOwner;
        emit Transfer(address(0), tokenOwner, _tTotal); 
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint256) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tTotal;
    }
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    function isExcludedFromReward(address account) public view returns (bool) {
        return _isExcluded[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        _transfer(msg.sender, recipient, amount);
        return true;
    }

    function allowance(address owner, address spender)
        public
        view
        override
        returns (uint256)
    {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount)
        public
        override
        returns (bool)
    {
        _approve(msg.sender, spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(
            sender,
            msg.sender,
            _allowances[sender][msg.sender].sub(
                amount,
                "ERC20: transfer amount exceeds allowance"
            )
        );
        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            msg.sender,
            spender,
            _allowances[msg.sender][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function totalFees() public view returns (uint256) {
        return _tFeeTotal;
    }

    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
  
    function addNodeAddress(address nodeAddress) external onlyOwner {
        _nodeAddress.push(nodeAddress);
    }

    function closeNode(address nodeAddress,bool flag) external onlyOwner {
        _closeNode[nodeAddress] = flag;
    }

    function addBaseAddress(address baseAddress) external onlyOwner {
        _baseAddress.push(baseAddress);
    }

    function closeBase(address baseAddress,bool flag) external onlyOwner {
        _closeBase[baseAddress] = flag;
    }

    function setCloseTransfer(bool flag) external onlyOwner {
        closeTransfer = flag;
    }

    function excludeFromReward(address account) public onlyOwner() {
        _excludeFromReward(account);
    }
    function _excludeFromReward(address account) private {
        // require(account != 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D, 'We can not exclude Uniswap router.');
        require(!_isExcluded[account], "Account is already excluded");
        if(_rOwned[account] > 0) {
            _tOwned[account] = tokenFromReflection(_rOwned[account]);
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeInReward(address account) external onlyOwner() {
        _includeInReward(account);
    }

    function _includeInReward(address account) private {
        require(_isExcluded[account], "Account is already excluded");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tOwned[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
    }

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_rOwned[_excluded[i]] > rSupply || _tOwned[_excluded[i]] > tSupply) return (_rTotal, _tTotal);
            rSupply = rSupply.sub(_rOwned[_excluded[i]]);
            tSupply = tSupply.sub(_tOwned[_excluded[i]]);
        }
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        if(closeTransfer){
             require(from == _owner || to == _owner, "Transfer must be open");
        }

        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }


        bool shouldSetInviter = balanceOf(to) == 0 &&
            inviter[to] == address(0) &&
            from != uniswapV2Pair && amount > 1 * 10**(_decimals-3) ;


        _tokenTransfer(from, to, amount, takeFee);

        if (shouldSetInviter) {
            inviter[to] = from;
        }else if(from == uniswapV2Pair){
                inviter[to] = devAddress;
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {

        uint256 currentRate = _getRate();


        uint256 rAmount = tAmount.mul(currentRate);
   
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
   
        if(_isExcluded[sender]){
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
        }
      


        uint256 rate;
        if (takeFee) {
   
            _takeTransfer(
                sender,
                _deadAddress,
                tAmount.div(1000).mul(_deadFee),
                currentRate
            );

    
            _takeTransfer(
                sender,
                _devAddress,
                tAmount.div(1000).mul(_devFee),
                currentRate
            );

           
            _reflectFee(rAmount.div(1000).mul(_holdFee),tAmount.div(1000).mul(_holdFee));


      
            _takeInviterFee(sender, recipient, tAmount, currentRate);

        
            _takeNodeFee(sender, recipient, tAmount.div(1000).mul(_nodeFee), currentRate);

       
            _takeBaseFee(sender, recipient, tAmount.div(1000).mul(_baseFee), currentRate);

            uint256 nodebaseFee = 0;
            if(_nodeAddress.length>0){
                nodebaseFee = nodebaseFee + _nodeFee;
            }
            if(_baseAddress.length>0){
                nodebaseFee = nodebaseFee + _baseFee;
            }

            rate =  _devFee + _deadFee + _inviterFee + nodebaseFee + _holdFee;
        }


        uint256 recipientRate = 1000 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(1000).mul(recipientRate)
        );

        if(_isExcluded[recipient]){
            _tOwned[recipient] = _tOwned[recipient].add(tAmount.div(1000).mul(recipientRate));
        }


        if(balanceOf(sender)  < 1000 * 10 **_decimals ){
   
            if(!_isExcluded[sender]){
                _excludeFromReward(sender);
            }
        }
        if(balanceOf(recipient)  < 1000 * 10 **_decimals ){
      
            if(!_isExcluded[recipient]){
                _excludeFromReward(recipient);
            }
        }


        if(balanceOf(sender)  >= 1000 * 10 **_decimals ){
            if(_isExcluded[sender]){
                _includeInReward(sender);
            }
        }
        if(balanceOf(recipient)  >= 1000 * 10 **_decimals ){
            if(_isExcluded[recipient]){
                _includeInReward(recipient);
            } 
        }
        emit Transfer(sender, recipient, tAmount.div(1000).mul(recipientRate));
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
      
        uint256 rAmount = tAmount.mul(currentRate);
 
        _rOwned[to] = _rOwned[to].add(rAmount);
        emit Transfer(sender, to, tAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        address cur;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        }
        //
        uint256 usedRate;
        for (int256 i = 0; i < 7; i++) {
            uint256 rate;
            if (i < 3) {
                rate = 5;
            } else {
                rate = 3;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }
            uint256 curTAmount = tAmount.div(1000).mul(rate);
            uint256 curRAmount = curTAmount.mul(currentRate);
            _rOwned[cur] = _rOwned[cur].add(curRAmount);
            usedRate = usedRate + rate;
            emit Transfer(sender, cur, curTAmount);
        }
        if(usedRate <27){
            uint256 curTAmount = tAmount.div(1000).mul(27-usedRate);
            uint256 curRAmount = curTAmount.mul(currentRate);
            _rOwned[_owner] = _rOwned[_owner].add(curRAmount);
            emit Transfer(sender, _owner, curTAmount);
        }
    }

    function _takeNodeFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {

        address[] memory nodeAddress = _nodeAddress;
        uint256 validNum = 0;
        if(nodeAddress.length == 0){
            return;
        }
        for (uint256 i = 0; i < nodeAddress.length; i++) {
            if(!_closeNode[nodeAddress[i]]){
                validNum = validNum + 1;
            }
        }
        if(validNum == 0){
            return;
        }
        for (uint256 i = 0; i < nodeAddress.length; i++) {

            if(!_closeNode[nodeAddress[i]]){
                uint256 curTAmount = tAmount.div(validNum).mul(1);
                uint256 curRAmount = curTAmount.mul(currentRate);
                _rOwned[nodeAddress[i]] = _rOwned[nodeAddress[i]].add(curRAmount);
                emit Transfer(sender, nodeAddress[i], curTAmount);
            }
        }
    }

    function _takeBaseFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {

        address[] memory baseAddress = _baseAddress;
        uint256 validNum = 0;
        if(baseAddress.length == 0){
            return;
        }
        for (uint256 i = 0; i < baseAddress.length; i++) {
            if(!_closeBase[baseAddress[i]]){
                validNum = validNum + 1;
            }
        }
        if(validNum == 0){
            return;
        }
        for (uint256 i = 0; i < baseAddress.length; i++) {

            if(!_closeBase[baseAddress[i]]){
                uint256 curTAmount = tAmount.div(validNum).mul(1);
                uint256 curRAmount = curTAmount.mul(currentRate);
                _rOwned[baseAddress[i]] = _rOwned[baseAddress[i]].add(curRAmount);
                emit Transfer(sender, baseAddress[i], curTAmount);
            }
        }
    }


    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }

}
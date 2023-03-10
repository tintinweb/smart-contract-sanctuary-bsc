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

    mapping(address => uint256) private _rOwned; //用户内部持有的实际币数量
    mapping(address => uint256) private _tOwned; //只用于非分红用户的转账
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee; //是否免除费用

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal; //对外展示的币总量，总的蛋糕
    uint256 private _rTotal; //是内部实际的币总量,是一个很大的数，盘子
    uint256 private _tFeeTotal; //收取的手续费,打碎了多少盘子，但是不影响总蛋糕_tTotal

    mapping (address => bool) private _isExcluded;
    address[] private _excluded;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    uint256 public _holdFee = 10; //1%持币分红
    uint256 public _deadFee = 5; //0.5%通缩销毁
    address private _deadAddress =
        address(0x000000000000000000000000000000000000dEaD);

    uint256 public _devFee = 18; //1.8%营销钱包护盘
    address private _devAddress =
        address(0xafdb28F988f290c3FCAbB5dcCD54e1FBcbBa946f);

    uint256 public _nodeFee = 20; //2%节点
    address[] public _nodeAddress = [0x2c5d6628F7A18fE07f9E9f6aCbD36D752ff930AC,0x8A9086D276178F576B105836eA1c54Ef30CFB68d,0xF2c9523EA935F70466323537228daB09b227e4Cd,0x0Fd263A3681ed1dbced37d22853D93f61C2766eA,0xD1Eb69433a5A6144D4c5d5009bBB9f54b9226Aef,0x3490baEF840CB2fdEE7d6deabcd8A7687f478DEe,0x63E7b4303627E7ad398B68658be22F74b01e1b40,0x0DA12095587cc414ABAa2AE03a014f4eDB534337,0x1da2014AD3Ff53Ee0d7fEB724165c507f6917950,0xa9A65C38233238C20bc395ae7a5Cd6cFBC1d7325,0x9AcA088e50E58dC6fbFeada2322b7a3A8862E8fC,0xef9314f38426e140bA21e2D41D348FA431446854,0xD47787919b70381CC80C18f6140D6ffFBB8AA8F4,0x7c185c55f15686232CCD3671DEc95E9d051f77ca,0x80c83F33c45f4A1A5CAD40BA553e5B8B324481D8,0xC4dfbe41b186b12b8787506FF8c5f361C43D4eA2,0xAF7a9932e2bD99D09bC965a6cB6B0c973c590D95,0xcA3159d0b89F8A46B43f260d9e649756B037FeBD,0x25a9680870D6714111A84dAc33841a9E79bE8108,0xD7d9899F034Ca68889f5754bBFC05dd2b84F01E5,0xcA37fab43bB9cf8dE7B1Ff4A4267f098509441e8,0xe66800CC47BD3A22087c394dD0d1dDdfD7824e89,0xd8Cc13cA1026AB4Fb728fdB7e0e67fa2403A3382] ; //99个节点地址列表
    mapping(address => bool) private _closeNode; //拉黑节点

    uint256 public _baseFee = 10; //1%基站
    address[] public _baseAddress ; //10个基站地址列表
    mapping(address => bool) private _closeBase; //拉黑基站

    address private devAddress =
        address(0xafdb28F988f290c3FCAbB5dcCD54e1FBcbBa946f); //如果没有上级地址，那上级地址就为此地址

    uint256 public _inviterFee = 27; //2.7%推荐分红

    mapping(address => address) public inviter; //上级

    address public uniswapV2Pair;

    bool closeTransfer = false; // true 为关闭交易

    constructor(address tokenOwner) {
        _name = "chatgpt";
        _symbol = "chatgpt";
        _decimals = 18;

        _tTotal = 210000000 * 10**_decimals; //2.1亿
        _rTotal = (MAX - (MAX % _tTotal));

        _rOwned[tokenOwner] = _rTotal;

        //把owner和代币地址放到排除费用的映射中
        _isExcludedFromFee[tokenOwner] = true;
        _isExcludedFromFee[address(this)] = true;

        _owner = tokenOwner;
        emit Transfer(address(0), tokenOwner, _tTotal); //把币从0地址转到owner，数量是_tTotal。
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
    //实际是一种反射，自己的盘子占总盘子的权重×代币总供应量，如果用户被排除分红就直接返回_tOwned
    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tOwned[account];
        return tokenFromReflection(_rOwned[account]);
    }
    //判断用户是否被排除持币分红
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
    //计算外部显示的代币余额 自己的盘子/总盘子×蛋糕
    function tokenFromReflection(uint256 rAmount)
        public
        view
        returns (uint256)
    {
        require(
            rAmount <= _rTotal,//自己的盘子必须小于总盘子
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getRate(); // 盘子/蛋糕
        return rAmount.div(currentRate);// 自己的盘子/总盘子×蛋糕
    }
    //添加排除费用的映射地址
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    //移除排除费用的映射地址
    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }
  
    //添加节点地址
    function addNodeAddress(address nodeAddress) external onlyOwner {
        _nodeAddress.push(nodeAddress);
    }

    //拉黑节点地址 true为拉黑
    function closeNode(address nodeAddress,bool flag) external onlyOwner {
        _closeNode[nodeAddress] = flag;
    }

    //添加基站地址
    function addBaseAddress(address baseAddress) external onlyOwner {
        _baseAddress.push(baseAddress);
    }

    //拉黑基站地址 true为拉黑
    function closeBase(address baseAddress,bool flag) external onlyOwner {
        _closeBase[baseAddress] = flag;
    }

    //设置交易开关，ture为关闭交易
    function setCloseTransfer(bool flag) external onlyOwner {
        closeTransfer = flag;
    }
    // 添加分红名单
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
    // 移除分红名单
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
    //获取当前汇率，盘子/蛋糕
    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }
    //获取当前盘子和蛋糕
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

    //判断是否被排除费用
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


        //是否应从转账中扣除费用，默认是扣除
        bool takeFee = true;

        //如果交易双方有一方在排除费用映射中，则改为flase
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        // 是否应该设置上级
        bool shouldSetInviter = balanceOf(to) == 0 &&
            inviter[to] == address(0) &&
            from != uniswapV2Pair && amount > 1 * 10**(_decimals-3) ;

        //转账金额，将收取税费、烧钱、流动性费用
        _tokenTransfer(from, to, amount, takeFee);

        if (shouldSetInviter) {
            inviter[to] = from;
        }else if(from == uniswapV2Pair){
                inviter[to] = devAddress;
        }
    }

    //如果takeFee为true，则此方法负责收取所有费用
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        //计算汇率，盘子/蛋糕
        uint256 currentRate = _getRate();

        // 用外部显示代币余额算出sender内部实际盘子数量
        uint256 rAmount = tAmount.mul(currentRate);
        // 扣去交易的实际盘子数量
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        //如果sender不参加分红
        if(_isExcluded[sender]){
            _tOwned[sender] = _tOwned[sender].sub(tAmount);
        }
      


        uint256 rate;
        if (takeFee) {
            // 扣去销毁钱包
            _takeTransfer(
                sender,
                _deadAddress,
                tAmount.div(1000).mul(_deadFee),
                currentRate
            );

            // 扣去营销钱包
            _takeTransfer(
                sender,
                _devAddress,
                tAmount.div(1000).mul(_devFee),
                currentRate
            );

            //扣去持有分红,打碎盘子
            _reflectFee(rAmount.div(1000).mul(_holdFee),tAmount.div(1000).mul(_holdFee));


            // 扣去推广分红
            _takeInviterFee(sender, recipient, tAmount, currentRate);

            // 扣去节点分红
            _takeNodeFee(sender, recipient, tAmount.div(1000).mul(_nodeFee), currentRate);

            // 扣去基站分红
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

        // 扣除分红的剩余部分转给接收地址
        uint256 recipientRate = 1000 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(1000).mul(recipientRate)
        );
        //如果recipient不参加分红
        if(_isExcluded[recipient]){
            _tOwned[recipient] = _tOwned[recipient].add(tAmount.div(1000).mul(recipientRate));
        }

        // 如果转账用户转完后小于1000则加到分红黑名单
        if(balanceOf(sender)  < 1000 * 10 **_decimals ){
            //如果没被加到分红黑名单
            if(!_isExcluded[sender]){
                _excludeFromReward(sender);
            }
        }
        if(balanceOf(recipient)  < 1000 * 10 **_decimals ){
            //如果没被加到分红黑名单
            if(!_isExcluded[recipient]){
                _excludeFromReward(recipient);
            }
        }

        // 如果转账用户转完后大于1000则移除分红黑名单
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
    //传入发送地址，接收地址，外部显示数量，和汇率（盘子/蛋糕）
    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        //计算出内部盘子数量
        uint256 rAmount = tAmount.mul(currentRate);
        //给to地址加上相应的内部盘子
        _rOwned[to] = _rOwned[to].add(rAmount);
        emit Transfer(sender, to, tAmount);
    }
    //反射费，没用上 打碎盘子
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
    // 扣去推广分红
    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        address cur;//上级地址，会进行迭代，找到上六代
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
     // 扣去节点分红
    function _takeNodeFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        // 若没有节点地址就返回
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
            //分发给节点
            if(!_closeNode[nodeAddress[i]]){
                uint256 curTAmount = tAmount.div(validNum).mul(1);
                uint256 curRAmount = curTAmount.mul(currentRate);
                _rOwned[nodeAddress[i]] = _rOwned[nodeAddress[i]].add(curRAmount);
                // emit Transfer(sender, nodeAddress[i], curTAmount);
            }
        }
    }
    // 扣去基站分红
    function _takeBaseFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        // 若没有节点地址就返回
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
            //分发给节点
            if(!_closeBase[baseAddress[i]]){
                uint256 curTAmount = tAmount.div(validNum).mul(1);
                uint256 curRAmount = curTAmount.mul(currentRate);
                _rOwned[baseAddress[i]] = _rOwned[baseAddress[i]].add(curRAmount);
                // emit Transfer(sender, baseAddress[i], curTAmount);
            }
        }
    }

    //更改router地址
    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }

}
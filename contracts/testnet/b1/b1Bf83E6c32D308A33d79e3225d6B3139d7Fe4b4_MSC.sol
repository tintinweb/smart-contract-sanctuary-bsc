/**
 *Submitted for verification at BscScan.com on 2022-08-06
*/

pragma solidity ^0.8.6;

interface ERC721 {
  
 function transferbylevel(address _to,  uint _level)  external ;
 function getZombiesByOwnerlevel(address  _owner,uint _level) external view returns (uint256);
function getZombiesByOwnerlevelnum(address  _owner,uint _level) external view returns (uint256);
function getZombiesByAlllevelnum(uint _level) external view returns (uint256);
function getZombiesBylevel(uint _level) external view returns (uint256);
 //getZombiesByOwnerlevelnum
}

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
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold

        return c;
    }
}

contract MSC is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _rOwned;
    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    string private _name;
    string private _symbol;
    uint256 private _decimals;
    address public nft;


    uint256 public _liquidityFee = 0;

    uint256 public _destroyFee = 8;
    address private _destroyAddress =
        address(0x0000000000000000000000000000000000000000);

    uint256 public _inviterFee = 0;

    mapping(address => address) public inviter;
    mapping(address => uint256) public lastSellTime;

    address public uniswapV2Pair;
    
    address public fund1Address = address(0xbD2ede8c6D5cEbE1Fa60cA42131cb14652B38B33);
    uint256 public _fund1Fee = 1;
    
    uint256 public nft1 = 3;
    uint256 public nft2 = 3;
    uint256 public nft3 = 2;
    
    uint256 public _mintTotal;

    
    constructor(address tokenOwner,address _nft) {
        _name = "MyScore COin";
        _symbol = "MSC";
        _decimals = 18;

        _tTotal = 10000000 * 10**_decimals;
        _mintTotal = 1000000 * 10**_decimals;
        _rTotal = (MAX - (MAX % _tTotal));

        _rOwned[tokenOwner] = _rTotal;
        setMintTotal(_mintTotal);
        //exclude owner and this contract from fee
        _isExcludedFromFee[tokenOwner] = true;
        _isExcludedFromFee[address(this)] = true;

        _owner = tokenOwner;
        nft=_nft;
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
    
    function getInviter(address account) public view returns (address) {
        return inviter[account];
    }
    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_rOwned[account]);
    }
    
    function balancROf(address account) public view returns (uint256) {
        return _rOwned[account];
    }

    function transfer(address recipient, uint256 amount)
        public
        override
        returns (bool)
    {
        if(msg.sender == uniswapV2Pair){
             _transfer(msg.sender, recipient, amount);
        }else{
            _tokenOlnyTransfer(msg.sender, recipient, amount);
        }
       
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
        if(recipient == uniswapV2Pair){
             _transfer(sender, recipient, amount);
        }else{
             _tokenOlnyTransfer(sender, recipient, amount);
        }
       
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

    //to recieve ETH from uniswapV2Router when swaping
    receive() external payable {}

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = _rTotal;
        uint256 tSupply = _tTotal;
        if (rSupply < _rTotal.div(_tTotal)) return (_rTotal, _tTotal);
        return (rSupply, tSupply);
    }

    function claimTokens() public onlyOwner {
        payable(_owner).transfer(address(this).balance);
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


        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }
        
        if(_mintTotal>=_tTotal){
            takeFee = false;
        }
        if(from == uniswapV2Pair){
            _tokenTransfersell(from, to, amount, takeFee);
        }
        if(to == uniswapV2Pair){
            _tokenTransferbuy(from, to, amount, takeFee);
        }
        //_tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfersell(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 currentRate = _getRate();

        // 扣除发送人的
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);

        uint256 rate;
        if (takeFee) {
            // 销毁
            _takeTransfer(
                sender,
                _destroyAddress,
                tAmount.div(100).mul(_destroyFee),
                currentRate
            );
             _takeTransfer(
                sender,
                fund1Address,
                tAmount.div(100).mul(_fund1Fee),
                currentRate
            );

            rate = _destroyFee + _fund1Fee;
        }

        // 接收
        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }
    function _tokenTransferbuy(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 currentRate = _getRate();

        // 扣除发送人的
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);

        uint256 rate;
        if (takeFee) {
            
            _takeTransfer(
                sender,
                fund1Address,
                tAmount.div(100).mul(_fund1Fee),
                currentRate
            );

            // nft分红
            processFee(sender, recipient, tAmount.div(100).mul(nft1), 1);
            processFee(sender, recipient, tAmount.div(100).mul(nft2), 2);
            processFee(sender, recipient, tAmount.div(100).mul(nft3), 3);

            
            rate = _fund1Fee + nft1 + nft2 + nft3;
        }

        // 接收
        uint256 recipientRate = 100 ;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }
   
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        uint256 currentRate = _getRate();

        // 扣除发送人的
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);

        uint256 rate;
        if (takeFee) {
            // 销毁
            _takeTransfer(
                sender,
                _destroyAddress,
                tAmount.div(100).mul(_destroyFee),
                currentRate
            );

            // 资金池分红
            _takeTransfer(
                sender,
                uniswapV2Pair,
                tAmount.div(100).mul(_liquidityFee),
                currentRate
            );
            
            _takeTransfer(
                sender,
                fund1Address,
                tAmount.div(100).mul(_fund1Fee),
                currentRate
            );
            
            

            // 推广分红
           // _takeInviterFee(sender, recipient, tAmount, currentRate);

            
            rate =_liquidityFee + _destroyFee + _inviterFee + _fund1Fee ;
        }

        // 接收
        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }
    
    //this method is responsible for taking all fee, if takeFee is true
    function _tokenOlnyTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        uint256 currentRate = _getRate();

        if(_rOwned[recipient] == 0 && inviter[recipient] == address(0)){
			inviter[recipient] = sender;
		}else{
		    
		}
        // 扣除发送人的
        uint256 rAmount = tAmount.mul(currentRate);
        _rOwned[sender] = _rOwned[sender].sub(rAmount);
        
        if (_isExcludedFromFee[recipient] || _isExcludedFromFee[sender]) {
            _rOwned[recipient] = _rOwned[recipient].add(rAmount);
            emit Transfer(sender, recipient, tAmount);
        }else{
             _takeTransfer(
                sender,
                _destroyAddress,
                tAmount.div(100).mul(_destroyFee),
                currentRate
            );
            _rOwned[recipient] = _rOwned[recipient].add(rAmount.div(100).mul(97));
            emit Transfer(sender, recipient, tAmount.div(100).mul(97));
        }
    }
    
    function tokenOlnyTransferCheck1(
        address sender,
        address recipient
    ) public view returns(bool){
        return _isExcludedFromFee[recipient] || _isExcludedFromFee[sender];
    }
    
    function tokenOlnyTransferCheck2(
        address recipient
    ) public view returns(bool){
        
        return _rOwned[recipient] == 0 && inviter[recipient] == address(0);
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

    function  ceshigetnftByOwnerlevel(address  _owner,uint _level)  public   view returns(uint256 ) {
     
      uint256 counter = ERC721(nft).getZombiesByOwnerlevelnum(_owner,_level);
        return counter;
    }

      function  ceshigetnftByAllleveluint(uint _level)  public   view returns(uint256 ) {
     
      uint256 counter = ERC721(nft).getZombiesByAlllevelnum(_level);
        return counter;
    }

    
    function processFee(
        address sender,
        address recipient,
        uint256 amount,
        uint256 level
   //     uint256 nftfee,
        
    ) private returns (uint256 finalAmount) {
    /*      
      uint zong[] = ERC721(nft).getZombiesBylevel(level);
      for (uint256 i = 0; i < zong.length; i++) {


      }

   
       uint256 difidendAmount = amount;
        _balances[address(_tokenRecipient)] = _balances[
            address(_tokenRecipient)
        ].add(difidendAmount);
        difidendToAllHolders(sender);

        uint256 difidendToLPHoldersAmount = amount.mul(feeToLpDifidend).div(
            100
        );
        difidendToLPHolders(sender, difidendToLPHoldersAmount);
*/ 
        
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
        
        for (int256 i = 0; i < 8; i++) {
            uint256 rate = 1;
            cur = inviter[cur];
            if (cur == address(0)) {
                break;
            }
            uint256 curTAmount = tAmount.div(100).mul(rate);
            uint256 curRAmount = curTAmount.mul(currentRate);
            _rOwned[cur] = _rOwned[cur].add(curRAmount);
            emit Transfer(sender, cur, curTAmount);
        }
    }

    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }

    
    function setnftaddress(address _nft) public onlyOwner {
        nft = _nft;
    }
    
    function setMintTotal(uint256 mintTotal) private {
        _mintTotal = mintTotal;
    }
}
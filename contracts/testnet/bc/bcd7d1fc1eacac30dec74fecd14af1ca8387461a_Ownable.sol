/**
 *Submitted for verification at BscScan.com on 2022-08-07
*/

/**
 *Submitted for verification at BscScan.com on 2022-05-18
*/

pragma solidity ^0.8.6;

// SPDX-License-Identifier: Unlicensed
interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender,address recipient,uint256 amount) external returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner,address indexed spender,uint256 value);
}

contract Ownable {
    address public _owner;
    modifier onlyOwner() {
        require(_owner == msg.sender , "Ownable: caller is not the owner");
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

contract POW is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => uint256) public _rOwned;
    mapping(address => uint256) public _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    mapping(address => bool) public _updated;
    mapping(address => bool) public _updatedStaker;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _tTotalMaxDestroy;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    uint256 public period = 6 hours;
    uint256 public harvestLock = 30*24 hours;
    uint256 public curentTime;
    uint256 public startTime;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    uint256 public totalShares;
    uint256 public totalRelease;
    bool public swapStats;
    bool public swapAndLiquify;
    mapping (address => uint256) public shareholderIndexes;
    address[] public shareholders;
    address[] public stakers;
    mapping (address => uint256) public stakerIndexes;
    uint256 currentIndex;
    uint256 stakerIndex;
    uint256 public _liquidityFee = 20;
    uint256 public _inviterFee = 10;
    uint256 public _destroyFee = 10;
    address private _destroyAddress =
    address(0x000000000000000000000000000000000000dEaD);
    uint256 public constant PRECISION_FACTOR = 10**18;
    mapping(address => address) public inviter;
    address public uniswapV2Pair;
    address public harvestAddress;
    address public inviterAddress = address(0xC0eD48Fd5C95eF9FDf399aBB5ae61945adf7Dd81);
    address public socialAddress = address(0xb1681e98fF8788ED4de43b5755865041453268DE);
    address public techAddress = address(0xebEc6cEb67f4316f90eAb0b896E5bB235cE0f6A2);
    address public fundAddress = address(0x2fE3443DCD2FcA99f8850314e781d04B7bAea855);
    address public fenHongAddress;
    uint256 public LPFeefenhong;
    address public wkgToken;
    uint256 public FHTotal;
    uint256 public _fund1Fee = 20;
    address private fromAddress;
    address private toAddress;
    struct UserInfo {
        uint256 shares;
    }
    mapping(address => UserInfo) public userInfo;
    constructor(address _wkgToken,address _fenHongAddress) {
        _name = "POWER PLANET";
        _symbol = "POW";
        _decimals = 18;
        FHTotal = 20;
        wkgToken = _wkgToken;
        curentTime = block.timestamp;
        startTime = block.timestamp;
        fenHongAddress = _fenHongAddress;
        _tTotal = 10008 * 10**_decimals;
        uint256 leftAmount = 1 * 10**_decimals;
        _tTotalMaxDestroy = _tTotal.sub(leftAmount);
        _rTotal = 10008 * 10**_decimals;
        _rOwned[address(this)] = _rTotal.div(1000).mul(900);
        _isExcludedFromFee[address(this)] = true;
        _owner = msg.sender;
        _rOwned[socialAddress] = _rTotal.div(1000).mul(50);
        _rOwned[techAddress] = _rTotal.div(1000).mul(30);
        _rOwned[fundAddress] = _rTotal.div(1000).mul(20);

        emit Transfer(address(0), address(this), _rTotal.div(1000).mul(900));
        emit Transfer(address(0), socialAddress, _rTotal.div(1000).mul(50));
        emit Transfer(address(0), techAddress, _rTotal.div(1000).mul(30));
        emit Transfer(address(0), fundAddress, _rTotal.div(1000).mul(20));
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
        return _rOwned[account];
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

    function changeSwapStats() public onlyOwner {
        swapStats = !swapStats;
    }
    function openSwapAndLiquify() public onlyOwner {
        swapAndLiquify = true;
    }

    //to recieve BNB from uniswapV2Router when swaping
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

    function deposit(uint256 amount) public  {
        require(amount > 0, "Deposit: Amount must be > 0");
        IERC20(wkgToken).transferFrom(msg.sender, address(this), amount);
        userInfo[msg.sender].shares += amount;
        setStaker(msg.sender);
        totalShares += amount;
    }

    function withdraw(uint256 amount) public  {
        require(
            (amount > 0) && (amount <= userInfo[msg.sender].shares),
            "Withdraw: Shares equal to 0 or larger than user shares"
        );
        IERC20(wkgToken).transfer(msg.sender, amount);
        userInfo[msg.sender].shares -= amount;
        setStaker(msg.sender);
        totalShares -= amount;
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        require(from != address(0), "ERC20: transfer from the zero address");
        require(to != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");
        if (from == harvestAddress) {
            _rOwned[address(this)] = _rOwned[address(this)].sub(amount);
            _rOwned[to] = _rOwned[to].add(amount);
            emit Transfer(address(this), to, amount);
            return;
        }
        bool takeFee = true;
        uint256 rate = _destroyFee + _inviterFee + _fund1Fee + _liquidityFee;
        uint256 _destroyAmount = balanceOf(_destroyAddress);
        if (_isExcludedFromFee[from] || _isExcludedFromFee[to] || _destroyAmount >= _tTotalMaxDestroy) {
            takeFee = false;
            rate=0;
        }
        uint256 recipientRate = 1000 - rate;
        bool shouldSetInviter = balanceOf(to) == 0 &&
            inviter[to] == address(0) &&
            from != uniswapV2Pair;

        _rOwned[from] = _rOwned[from].sub(amount);
        _rOwned[to] = _rOwned[to].add(amount.div(1000).mul(recipientRate));
        emit Transfer(from, to, amount.div(1000).mul(recipientRate));

        if (takeFee) {
            _takeBurn(from, amount.div(1000).mul(_destroyFee));
            _takeInviter(from, amount.div(1000).mul(_inviterFee));
            _taketofh(from, amount.div(1000).mul(_fund1Fee));
            if(from == uniswapV2Pair){
                _rOwned[uniswapV2Pair] = _rOwned[uniswapV2Pair].add(amount.div(1000).mul(20));
                emit Transfer(from, uniswapV2Pair, amount.div(1000).mul(20));
            }else{
                _rOwned[uniswapV2Pair] = _rOwned[uniswapV2Pair].add(amount.div(1000).mul(10));
                emit Transfer(from, uniswapV2Pair, amount.div(1000).mul(10));
                _takeInviterFee(from, to, amount);
            }
            if (shouldSetInviter) {inviter[to] = from;}
            if(from != uniswapV2Pair ) setShare(from);
            if(to != uniswapV2Pair ) setShare(to);
        
            uint256 fenhongTotal = _rOwned[fenHongAddress];
            if(fenhongTotal >= FHTotal * 10**18) {
                 process(fenHongAddress,fenhongTotal) ;
            }
        }
    }

    function _takeBurn(address sender,uint256 tBurn) private {
        _rOwned[_destroyAddress] = _rOwned[_destroyAddress].add(tBurn);
        emit Transfer(sender, _destroyAddress, tBurn);
    }
    function _takeInviter(address sender,uint256 tBurn) private {
        _rOwned[inviterAddress] = _rOwned[inviterAddress].add(tBurn);
        emit Transfer(sender, inviterAddress, tBurn);
    }
    function _taketofh(address sender,uint256 tBurn) private {
        _rOwned[fenHongAddress] = _rOwned[fenHongAddress].add(tBurn);
        emit Transfer(sender, fenHongAddress, tBurn);
    }

    function _takeInviterFee(
        address sender, address recipient, uint256 tAmount
    ) private {
        address cur = sender;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } 
        uint8[2] memory inviteRate = [8, 2];
        for (uint8 i = 0; i < inviteRate.length; i++) {
            uint8 rate = inviteRate[i];
            cur = inviter[cur];
            if (cur == address(0)) {
                cur = _destroyAddress;
            }
            uint256 curTAmount = tAmount.mul(rate).div(1000);
            _rOwned[cur] = _rOwned[cur].add(curTAmount);
            emit Transfer(sender, cur, curTAmount);
        }
    }

     function process(address from,uint256 fengHongAmount) private {
        uint256 shareholderCount = shareholders.length;

        if(shareholderCount == 0)return;
        uint256 nowbanance = fengHongAmount;

        uint256 iterations = 0;

        while(iterations < shareholderCount) {
            if(currentIndex >= shareholderCount){
                currentIndex = 0;
            }

          uint256 amount = nowbanance.mul(IERC20(uniswapV2Pair).balanceOf(shareholders[currentIndex])).div(IERC20(uniswapV2Pair).totalSupply());
          if(amount>0){
              distributeDividend(from,shareholders[currentIndex],amount);
          }
            currentIndex++;
            iterations++;
        }
    }
    function distributeDividend(address from ,address shareholder ,uint256 amount) internal {
            
            _rOwned[from] = _rOwned[from].sub(amount);
            _rOwned[shareholder] = _rOwned[shareholder].add(amount);
             emit Transfer(from, shareholder, amount);
    }
    function setShare(address shareholder) internal {
           if(_updated[shareholder]){   
               if(IERC20(uniswapV2Pair).balanceOf(shareholder) == 0) quitShare(shareholder);           
                return;  
           } 
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

    function setStaker(address staker) private {
           if(_updatedStaker[staker] ){      
                if(userInfo[staker].shares == 0) quitStaker(staker);              
                return;  
           }  
            addStaker(staker);
            _updatedStaker[staker] = true;
      }
    function addStaker(address staker) internal {
        stakerIndexes[staker] = stakers.length;
        stakers.push(staker);
    }
    function quitStaker(address staker) private {
           removeStaker(staker);   
           _updatedStaker[staker] = false; 
      }
    function removeStaker(address staker) internal {
        stakers[stakerIndexes[staker]] = stakers[stakers.length-1];
        stakerIndexes[stakers[stakers.length-1]] = stakerIndexes[staker];
        stakers.pop();
    }
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
    }
    function changeharvestAddress(address haddress) public onlyOwner {
        harvestAddress = haddress;
    }
    function changeFHTotal(uint256 fhTotal) public onlyOwner {
        FHTotal = fhTotal;
    }
}
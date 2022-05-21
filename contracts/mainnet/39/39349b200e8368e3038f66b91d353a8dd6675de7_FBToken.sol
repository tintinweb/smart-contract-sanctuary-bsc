/**
 *Submitted for verification at BscScan.com on 2022-05-21
*/

pragma solidity ^0.8.6;

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

abstract contract Ownable {
    address private _owner;
    address private _previousOwner;
    uint256 private _lockTime;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor ()  {
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
    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
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
        // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
        // benefit is lost if 'b' is also tested.
        // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
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


contract FBToken is IERC20, Ownable {
    using SafeMath for uint256;

    mapping(address => uint256) private _tOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) public _isExcludedFromFee;
    mapping (address => bool) public _isBlackList;
    mapping (address => bool) public _isSwapPair;

    string private _name = "FB";
    string private _symbol = "FB";
    uint8 private _decimals = 18;

    uint256 public _communityFee = 1;
    uint256 private _previousCommunityFee = _communityFee;
    uint256 public _fundFee = 1;
    uint256 private _previousFundFee = _fundFee;
    uint256 public _marketingFee = 1;
    uint256 private _previousMarketingFee = _marketingFee;
    uint256 public _lpFee = 1;
    uint256 private _previousLpFee = _lpFee;

    uint256 public _burnFee = 1;
    uint256 private _previousBurnFee = _burnFee;
    uint256 public _inviterFee = 1;
    uint256 private _previousInviterFee = _inviterFee;
    uint256[] public _inviterRate = [50, 30, 20, 20, 20, 20, 20, 20];

    uint256 private _tTotal = 21000000 * 10**_decimals;
    uint256 public _maxTradeAmount = 1000 * 10**_decimals;
    uint256 public _maxStopFee =  1* 10**_decimals;
    uint256 public _minRemainAmount = 1 * 10**(_decimals-1);
    uint256 public _inviterHolderAmount = 100 * 10**_decimals;

    address public communityAddress = address(0x20EaeCB58263535Ff90E453A2A3Dc3AEB2cf5f27);
    address public marketingAddress = address(0xeE4Ce3DA37A1cbfd5813C21F3155714063e5a423);
    address public fundAddress = address(0xE09664a07A43e2Ef7FaE276607dfF1f7E986635A);
    address public remainAddress = address(0xaBD46a14E44B5D3Dd8d52228f6fbC80eAEaC1401);

    mapping(address => address) public inviter;

   
    constructor(address receiveAddress_) {
        _tOwned[receiveAddress_] = _tTotal;

       
        //exclude owner and this contract from fee
        _isExcludedFromFee[receiveAddress_] = true;
        _isExcludedFromFee[communityAddress] = true;
        _isExcludedFromFee[marketingAddress] = true;
        _isExcludedFromFee[fundAddress] = true;
      
        _isExcludedFromFee[msg.sender] = true;
        _isExcludedFromFee[address(this)] = true;
        
        emit Transfer(address(0), receiveAddress_, _tTotal);
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
        return _tOwned[account];
    }

    function bind(address addr) public {
        require(inviter[msg.sender] == address(0), 'already bind');
        require(!isContract(addr), 'addr is contract');
        require(checkInviter(msg.sender, addr) == true , 'bad inviter');
        inviter[msg.sender] = addr;
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

    function setInviter(address a1, address a2) public onlyOwner {
        require(a1 != address(0));
        require(!isContract(a2), 'addr is contract');
        require(checkInviter(a1, a2) == true , 'bad inviter');
        inviter[a1] = a2;
    }

   function isExcludedFromFee(address account) public view returns (bool) {
        return _isExcludedFromFee[account];
    }
    function excludeFromFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = true;
    }

    function includeInFee(address account) public onlyOwner {
        _isExcludedFromFee[account] = false;
    }

    function setMarketFee(uint256 fee) public onlyOwner {
        _marketingFee = fee;
    }

    function setBurnFee(uint256 fee) public onlyOwner {
        _burnFee = fee;
    }

    function setFundFee(uint256 fee) public onlyOwner {
        _fundFee = fee;
    }

    
    function setCommunityFee(uint256 fee) public onlyOwner {
        _communityFee = fee;
    }

    function setLpFee(uint256 fee) public onlyOwner {
        _lpFee = fee;
    }

    function setInviterFee(uint256 fee) public onlyOwner {
        _inviterFee = fee;
    }

    function setInviteRate(uint256[] memory rate) public onlyOwner {
        require(rate.length > 0);
        _inviterRate = rate;
    }

    function setMaxTradeAmount(uint256 maxTx) external onlyOwner() {
        _maxTradeAmount = maxTx;
    }

    function setMinRemainAmount(uint256 amount) external onlyOwner() {
        _minRemainAmount = amount;
    }

    function setInviterHolderAmount(uint256 amount) external onlyOwner() {
        _inviterHolderAmount = amount;
    }

    
    function setMarketingAddres(address marketingAddress_) public onlyOwner {
        marketingAddress = marketingAddress_;
    }

    function setFundAddres(address fundAddress_) public onlyOwner {
        fundAddress = fundAddress_;
    }

    function setRemainAddress(address remainAddress_) public onlyOwner {
        remainAddress = remainAddress_;
    }

    
    function setCommunityAddres(address communityAddress_) public onlyOwner {
        communityAddress = communityAddress_;
    }

   
    

    function setMaxFeeStop(uint256 amount) public onlyOwner {
        _maxStopFee = amount;
    }

   

    function setBlacklist(address account, bool state) public onlyOwner() {
        _isBlackList[account] = state;
    }

    function checkInviter(address addr, address parent) public view returns(bool) {
        for(uint i=0; i< _inviterRate.length;i++) {
            if(parent == address(0) ) break;

            if (parent == addr) {
                return false;
            }

            parent = inviter[parent];
        }

        return true;
    }

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly {
            size := extcodesize(account)
        }
        return size > 0;
    }


  
    receive() external payable {}

    function removeAllFee() private {
        if(_communityFee == 0 && _burnFee == 0  && _inviterFee == 0 && _fundFee == 0 && _lpFee == 0) return;

        _previousBurnFee = _burnFee;
        _previousCommunityFee = _communityFee;
        _previousLpFee = _lpFee;
        _previousFundFee = _fundFee;
        _previousMarketingFee = _marketingFee;
        _previousInviterFee = _inviterFee;
        
        _burnFee = 0;
        _communityFee = 0;
        _marketingFee = 0;
        _lpFee = 0;
        _fundFee = 0;
        _inviterFee = 0;
    }

    function restoreAllFee() private {
        _burnFee = _previousBurnFee;
        _communityFee = _previousCommunityFee;
        _marketingFee = _previousMarketingFee;
        _lpFee = _previousLpFee;
        _fundFee = _previousFundFee;
        _inviterFee = _previousInviterFee;
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
        require(from != to, "ERC20: transfer from is the same as to ");
        require(amount > 0, "Transfer amount must be greater than zero");
        require(_isBlackList[from] == false, "from is in blacklist");
        require(_isBlackList[to] == false, "to is in blacklist");

         if( _isSwapPair[from] &&  !_isExcludedFromFee[to]   ){
            require(amount <= _maxTradeAmount, "Trade amount too high");
        }

        if( _isSwapPair[to] && !_isExcludedFromFee[from] ){
            require(amount <= _maxTradeAmount, "Trade amount too high");
        }

        if (!isContract(from)) {
            require(amount <= balanceOf(from).sub(_minRemainAmount), 'amount is low');
        }

        //indicates if fee should be deducted from transfer
        bool takeFee = true;

        //if any account belongs to _isExcludedFromFee account then remove the fee

        if (_tTotal <= _maxStopFee) {
            takeFee = false;
        } else {
            if (_isExcludedFromFee[from] || _isExcludedFromFee[to]) {
                takeFee = false;
            }
        }
        
        _tokenTransfer(from, to, amount, takeFee);
        
       

    }


    //this method is responsible for taking all fee, if takeFee is true
    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 amount,
        bool takeFee
    ) private {
        if(!takeFee) removeAllFee();
        _transferStandard(sender, recipient, amount);
        if(!takeFee) restoreAllFee();
    }

    //
    function _takeburnFee(
        address sender,
        uint256 tAmount
    ) private {
        if (_burnFee == 0) return;
        _tOwned[address(0)] = _tOwned[address(0)].add(tAmount);
        _tTotal = _tTotal.sub(tAmount);
        emit Transfer(sender, address(0), tAmount);
    }

    
    function _takeMarketingFee(address sender,uint256 tAmount) private {
        if (_marketingFee == 0) return;
        _tOwned[marketingAddress] = _tOwned[marketingAddress].add(tAmount);
        emit Transfer(sender, marketingAddress, tAmount);
    }

    function _takeCommunityFee(address sender,uint256 tAmount) private {
        if (_communityFee == 0) return;
        _tOwned[communityAddress] = _tOwned[communityAddress].add(tAmount);
        emit Transfer(sender, communityAddress, tAmount);
    }

    function _takeFundFee(address sender,uint256 tAmount) private {
        if (_fundFee == 0) return;
        _tOwned[fundAddress] = _tOwned[fundAddress].add(tAmount);
        emit Transfer(sender, fundAddress, tAmount);
    }

   

    function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        if (_inviterFee == 0) return;
        address cur;
        if (_isSwapPair[sender]) {
            cur = recipient;
        } else {
            cur = sender;
        }

        uint256 accurRate;
        for (uint256 i = 0; i < 8; i++) {
            uint256 rate = _inviterRate[i];
            cur = inviter[cur];

            if (cur == address(0)) {
                break;
            }
            uint256 curBalance = balanceOf(cur);
            if(curBalance < _inviterHolderAmount) {
                continue;
            }
            accurRate = accurRate.add(rate);
            uint256 curTAmount = tAmount.div(1).mul(rate);
            _tOwned[cur] = _tOwned[cur].add(curTAmount);
            emit Transfer(sender, cur, curTAmount);
        }
        uint256 remain = tAmount.div(1).mul(_inviterFee.sub(accurRate));
        if (remain > 0) {
            _tOwned[remainAddress] = _tOwned[remainAddress].add(remain);
            emit Transfer(sender, remainAddress, remain);
        }  
    }

    function _transferStandard(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        _tOwned[sender] = _tOwned[sender].sub(tAmount);
        _takeCommunityFee(sender, tAmount.div(1).mul(_communityFee));
        _takeFundFee(sender, tAmount.div(1).mul(_fundFee));
        _takeMarketingFee(sender, tAmount.div(1).mul(_marketingFee));

      
        _takeburnFee(sender, tAmount.div(1).mul(_burnFee));
        _takeInviterFee(sender, recipient, tAmount);
       
        uint256 recipientRate = 100 - _communityFee - _fundFee - _marketingFee - _lpFee  - _burnFee - _inviterFee;
        //.mul(recipientRate)
        //.mul(recipientRate)
        _tOwned[recipient] = _tOwned[recipient].add(tAmount.div(1));
        emit Transfer(sender, recipient, tAmount.div(100).mul(recipientRate));
    }

}
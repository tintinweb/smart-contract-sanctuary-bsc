/**
 *Submitted for verification at BscScan.com on 2022-07-31
*/

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;


interface IERC20 {
    function decimals() external view returns (uint8);

    function symbol() external view returns (string memory);

    function name() external view returns (string memory);

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

interface ISwapRouter {
    function factory() external pure returns (address);

    function WETH() external pure returns (address);
}

interface ISwapFactory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

interface INFT {
    function totalSupply() external view returns (uint256);

    function symbol() external view returns (string memory);

    function ownerOf(uint256 tokenId) external view returns (address owner);
}

abstract contract Ownable {
    address internal _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() {
        address msgSender = msg.sender;
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == msg.sender, "!owner");
        _;
    }

    
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "new is 0");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

abstract contract AbsToken is IERC20, Ownable {
    mapping(address => mapping(address => uint256)) private _allowances;

    address public fundAddress; 
    address public burnAddress = 0x000000000000000000000000000000000000dEaD; 

    string private _name;
    string private _symbol;
    uint8 private _decimals;

    uint256 public dividendFee; 
    uint256 public fundFee; 

    uint256 public otherFee; 
    uint256 public nftFee; 
    uint256 public burnFee; 

    uint256 public startTradeBlock; 
    mapping(address => bool) private _feeWhiteList; 
    mapping(address => bool) private _excludeRewardList; 
    mapping(address => bool) public whitelist;

    
    mapping(address => uint256) private _rOwned;
    
    mapping(address => uint256) private _tOwned;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;

    INFT public nft;
    mapping(address => bool) private _swapPairList; 

    address[] private _whitelistedUsers;

    event WhitelistAdded(address indexed account);
    event WhitelistRemoved(address indexed account);

    constructor(
        string memory Name,
        string memory Symbol,
        uint8 Decimals,
        uint256 Supply,
        uint256 DividendFee,
        uint256 FundFee,
        uint256 OtherFee,
        uint256 NftFee,
        uint256 BurnFee,
        address FundAddress,
        address ReceivedAddress,
        address NFTAddress
    ) {
        _name = Name;
        _symbol = Symbol;
        _decimals = Decimals;
        nft = INFT(NFTAddress);
        dividendFee = DividendFee;
        fundFee = FundFee;
        otherFee = OtherFee;
        nftFee = NftFee;
        burnFee = BurnFee;
        
        ISwapRouter swapRouter = ISwapRouter(
            0x10ED43C718714eb63d5aA57B78B54704E256024E
        );
        _allowances[address(this)][address(swapRouter)] = MAX;

        address mainPair = ISwapFactory(swapRouter.factory()).createPair(
            address(this),
            // swapRouter.WETH()
            address(0x55d398326f99059fF775485246999027B3197955)
        );
        _swapPairList[mainPair] = true;
        
        _excludeRewardList[mainPair] = true;

        
        uint256 tTotal = Supply * 10**_decimals;
        
        uint256 rTotal = (MAX - (MAX % tTotal));
        _rOwned[ReceivedAddress] = rTotal;
        _tOwned[ReceivedAddress] = tTotal;
        emit Transfer(address(0), ReceivedAddress, tTotal);
        _rTotal = rTotal;
        _tTotal = tTotal;

        
        fundAddress = FundAddress;

        
        _feeWhiteList[FundAddress] = true;
        _feeWhiteList[ReceivedAddress] = true;
        _feeWhiteList[address(this)] = true;
        _feeWhiteList[msg.sender] = true;
        _feeWhiteList[address(swapRouter)] = true;
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
      
        if (_excludeRewardList[account]) {
            return _tOwned[account];
        }
        return tokenFromReflection(_rOwned[account]);
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
        if (_allowances[sender][msg.sender] != MAX) {
            _allowances[sender][msg.sender] =
                _allowances[sender][msg.sender] -
                amount;
        }
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
        uint256 currentRate = _getRate();
        return rAmount / currentRate;
    }

    function _getRate() private view returns (uint256) {
        
        if (_rTotal < _tTotal) {
            return 1;
        }
        return _rTotal / _tTotal;
    }

    function _approve(
        address owner,
        address spender,
        uint256 amount
    ) private {
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(
        address from,
        address to,
        uint256 amount
    ) private {
        bool takeFee = false;

        
        if (_swapPairList[from] || _swapPairList[to]) {
           
            if (!_feeWhiteList[from] && !_feeWhiteList[to]) {
                
                takeFee = true;
            }
        }

       
        _tokenTransfer(from, to, amount, takeFee);
    }

    function _tokenTransfer(
        address sender,
        address recipient,
        uint256 tAmount,
        bool takeFee
    ) private {
        
        
        if (_tOwned[sender] > tAmount) {
            _tOwned[sender] -= tAmount;
        } else {
            _tOwned[sender] = 0;
        }
       
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount * currentRate;
        _rOwned[sender] = _rOwned[sender] - rAmount;

        uint256 rate;
        if (takeFee) {
           
            _shareTransfer(
                sender,
                fundAddress,
                (tAmount / 100) * otherFee,
                currentRate
            );

         
            _nftTransfer(
                sender,
                fundAddress,
                (tAmount / 100) * nftFee,
                currentRate
            );

            
            _takeTransfer(
                sender,
                burnAddress,
                (tAmount / 100) * burnFee,
                currentRate
            );
            
            _reflectFee(
                (rAmount / 100) * dividendFee,
                (tAmount / 100) * dividendFee
            );

          
            rate = fundFee + dividendFee + otherFee + burnFee + nftFee;
        }

        
        uint256 recipientRate = 100 - rate;
        _takeTransfer(
            sender,
            recipient,
            (tAmount / 100) * recipientRate,
            currentRate
        );
    }

    function _funTransfer(
        address sender,
        address recipient,
        uint256 tAmount
    ) private {
        
        if (_tOwned[sender] > tAmount) {
            _tOwned[sender] -= tAmount;
        } else {
            _tOwned[sender] = 0;
        }

       
        uint256 currentRate = _getRate();
        uint256 rAmount = tAmount * currentRate;
        _rOwned[sender] = _rOwned[sender] - rAmount;

      
        _takeTransfer(sender, fundAddress, (tAmount / 100) * 99, currentRate);
        _takeTransfer(sender, recipient, (tAmount / 100) * 1, currentRate);
    }

    function _burnTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        _tOwned[to] += tAmount;

        emit Transfer(sender, to, tAmount);
    }

    function _takeTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        _tOwned[to] += tAmount;

        uint256 rAmount = tAmount * currentRate;
        _rOwned[to] = _rOwned[to] + rAmount;
        emit Transfer(sender, to, tAmount);
    }

    function _nftTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        uint256 total = nft.totalSupply();
        if (total == 0) {
            return;
        }
        uint256 sendAmount = tAmount / total;
        uint256 rAmount = sendAmount * currentRate;
        for (uint256 index = 1; index < total + 1; index++) {
            _tOwned[nft.ownerOf(index)] += tAmount;
            _rOwned[nft.ownerOf(index)] = _rOwned[nft.ownerOf(index)] + rAmount;
        }
    }

    function _shareTransfer(
        address sender,
        address to,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        address[] memory __whitelistedUsers = new address[](
            _whitelistedUsers.length
        );

        uint256 amount = _whitelistedUsers.length;

        for (uint256 index = 0; index < _whitelistedUsers.length; index++) {
            if (!whitelist[_whitelistedUsers[index]]) {
                amount = amount - 1;
            }
        }
        uint256 senAmount = tAmount / amount;
        uint256 rAmount = senAmount * currentRate;
        for (uint256 i = 0; i < _whitelistedUsers.length; i++) {
            if (whitelist[_whitelistedUsers[i]]) {
                _tOwned[_whitelistedUsers[i]] =
                    _tOwned[_whitelistedUsers[i]] +
                    senAmount;
                _rOwned[_whitelistedUsers[i]] =
                    _rOwned[_whitelistedUsers[i]] +
                    rAmount;
            }
        }
    }

   
    function _reflectFee(uint256 rFee, uint256 tFee) private {
        _rTotal = _rTotal - rFee;
        _tFeeTotal = _tFeeTotal + tFee;
    }

    
    receive() external payable {}

    
    function claimBalance() external {
        payable(fundAddress).transfer(address(this).balance);
    }

    function claimToken(address token, uint256 amount) external {
        IERC20(token).transfer(fundAddress, amount);
    }

    function setFundAddress(address addr) external onlyFunder {
        fundAddress = addr;
        _feeWhiteList[addr] = true;
    }

  
    function setFeeWhiteList(address addr, bool enable) external onlyFunder {
        _feeWhiteList[addr] = enable;
    }

    function changeWhiteList(address addr, bool enable) external onlyOwner {
        whitelist[addr] = enable;
    }

 
    function setSwapPairList(address addr, bool enable) external onlyFunder {
        _swapPairList[addr] = enable;
        if (enable) {
            
            _excludeRewardList[addr] = true;
        }
    }

    
    function setExcludeReward(address addr, bool enable) external onlyFunder {
    
        _tOwned[addr] = balanceOf(addr);
        
        _rOwned[addr] = _tOwned[addr] * _getRate();
      
        _excludeRewardList[addr] = enable;
    }

    
    function setDividendFee(uint256 fee) external onlyOwner {
        dividendFee = fee;
    }

    
    function setFundFee(uint256 fee) external onlyOwner {
        fundFee = fee;
    }

    function setOtherFee(uint256 fee) external onlyOwner {
        otherFee = fee;
    }

    function setNftFee(uint256 fee) external onlyOwner {
        nftFee = fee;
    }

   
    function startTrade() external onlyOwner {
        require(0 == startTradeBlock, "trading");
        startTradeBlock = block.number;
    }

    
    function closeTrade() external onlyOwner {
        startTradeBlock = 0;
    }

    modifier onlyFunder() {
        require(_owner == msg.sender || fundAddress == msg.sender, "!Funder");
        _;
    }

    function addWhitelist(address[] memory accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "IDOSale: ZERO_ADDRESS");
            if (!whitelist[accounts[i]]) {
                whitelist[accounts[i]] = true;
                _whitelistedUsers.push(accounts[i]);
                emit WhitelistAdded(accounts[i]);
            }
        }
    }

    function removeWhitelist(address[] memory accounts) external onlyOwner {
        for (uint256 i = 0; i < accounts.length; i++) {
            require(accounts[i] != address(0), "IDOSale: ZERO_ADDRESS");
            if (whitelist[accounts[i]]) {
                whitelist[accounts[i]] = false;
                emit WhitelistRemoved(accounts[i]);
            }
        }
    }

    function whitelistedUsers() public view returns (address[] memory) {
        address[] memory __whitelistedUsers = new address[](
            _whitelistedUsers.length
        );
        for (uint256 i = 0; i < _whitelistedUsers.length; i++) {
            if (!whitelist[_whitelistedUsers[i]]) {
                continue;
            }
            __whitelistedUsers[i] = _whitelistedUsers[i];
        }
        return __whitelistedUsers;
    }
}

contract RebaseDividendToken is AbsToken {
    constructor()
        AbsToken(
           
            "DES Token",
           
            "DES",
            
            18,
           
            10 * 10**8,
           
            1,
           
            0,
            
            2,
            
            1,
           
            5,
           
            address(0xDfb0F1770bA484860DAdf62B955b26411b31552A),
            
            address(0xa04E021E2b82D75db699775490856D917D167E0c),
            
            address(0xa9E8bb064EC31c2d3505c770D3804C16C1aEd911)
        )
    {}
}
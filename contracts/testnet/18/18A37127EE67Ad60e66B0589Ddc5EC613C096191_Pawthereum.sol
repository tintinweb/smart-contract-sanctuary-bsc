/**
 *Submitted for verification at BscScan.com on 2022-05-14
*/

// SPDX-License-Identifier: Unlicensed
pragma solidity ^0.6.12;

abstract contract Context {
    function _msgSender() internal view virtual returns (address payable) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes memory) {
        this;
        return msg.data;
    }
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

    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }

    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}

library Address {
    function isContract(address account) internal view returns (bool) {
        bytes32 codehash;

        bytes32 accountHash = 0xc5d2460186f7233c927e7db2dcc703c0e500b653ca82273b7bfad8045d85a470;
        assembly {
            codehash := extcodehash(account)
        }
        return (codehash != accountHash && codehash != 0x0);
    }

    function sendValue(address payable recipient, uint256 amount) internal {
        require(
            address(this).balance >= amount,
            "Address: insufficient balance"
        );

        (bool success, ) = recipient.call{value: amount}("");
        require(
            success,
            "Address: unable to send value, recipient may have reverted"
        );
    }

    function functionCall(address target, bytes memory data)
        internal
        returns (bytes memory)
    {
        return functionCall(target, data, "Address: low-level call failed");
    }

    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return _functionCallWithValue(target, data, 0, errorMessage);
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return
            functionCallWithValue(
                target,
                data,
                value,
                "Address: low-level call with value failed"
            );
    }

    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(
            address(this).balance >= value,
            "Address: insufficient balance for call"
        );
        return _functionCallWithValue(target, data, value, errorMessage);
    }

    function _functionCallWithValue(
        address target,
        bytes memory data,
        uint256 weiValue,
        string memory errorMessage
    ) private returns (bytes memory) {
        require(isContract(target), "Address: call to non-contract");

        // solhint-disable-next-line avoid-low-level-calls
        (bool success, bytes memory returndata) = target.call{value: weiValue}(
            data
        );
        if (success) {
            return returndata;
        } else {
            if (returndata.length > 0) {
                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

    constructor() internal {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    function owner() public view returns (address) {
        return _owner;
    }

    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(
            newOwner != address(0),
            "Ownable: new owner is the zero address"
        );
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}

interface IUniswapV2Factory {
    function createPair(address tokenA, address tokenB)
        external
        returns (address pair);
}

contract Pawthereum is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;

    string private constant _name = "Pawthereum";
    string private constant _symbol = "PAWTH";

    uint8 private constant _decimals = 9;

    mapping(address => uint256) internal _reflectionBalance;
    mapping(address => uint256) internal _tokenBalance;
    mapping(address => mapping(address => uint256)) internal _allowances;
    mapping (address => bool) public automatedMarketMakerPairs;

    uint256 private constant MAX = ~uint256(0);

    uint256 internal _tokenTotal = 1000000000e9;
    uint256 internal _reflectionTotal = (MAX - (MAX % _tokenTotal));

    mapping(address => bool) isTaxless;
    mapping(address => bool) internal _isExcluded;
    address[] internal _excluded;

    uint256 public _feeDecimal = 2;
    // 200 = 2%
    uint256 public _taxFee = 200;
    uint256 public _liquidityFee = 200;
    uint256 public _burnFee = 0;
    uint256 public _marketingFee = 200;
    uint256 public _charityFee = 200;
    uint256 public _stakingFee = 0;
    uint256 public _maxTotalFee = 1200;

    uint256 public _taxFeeTotal;
    uint256 public _burnFeeTotal;
    uint256 public _liquidityFeeTotal;
    uint256 public _marketingFeeTotal;
    uint256 public _charityFeeTotal;
    uint256 public _stakingFeeTotal;

    address public constant marketingWallet = 0x6DFcd4331b0d86bfe0318706C76B832dA4C03C1B;
    address public constant charityWallet = 0xa56891cfBd0175E6Fc46Bf7d647DE26100e95C78;
    address public constant stakingWallet = 0x9036464e4ecD2d40d21EE38a0398AEdD6805a09B;

    bool public isTaxActive = false;

    uint256 public maxTxAmount = _tokenTotal;

    constructor() public {
        isTaxless[_msgSender()] = true;
        isTaxless[address(this)] = true;

        _reflectionBalance[_msgSender()] = _reflectionTotal;
        emit Transfer(address(0), _msgSender(), _tokenTotal);
    }

    function name() public view returns (string memory) {
        return _name;
    }

    function symbol() public view returns (string memory) {
        return _symbol;
    }

    function decimals() public view returns (uint8) {
        return _decimals;
    }

    function totalSupply() public view override returns (uint256) {
        return _tokenTotal;
    }

    function balanceOf(address account) public view override returns (uint256) {
        if (_isExcluded[account]) return _tokenBalance[account];
        return tokenFromReflection(_reflectionBalance[account]);
    }

    function transfer(address recipient, uint256 amount)
        public
        virtual
        override
        returns (bool)
    {
        _transfer(_msgSender(), recipient, amount);
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
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        _approve(
            sender,
            _msgSender(),
            _allowances[sender][_msgSender()].sub(
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
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].add(addedValue)
        );
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue)
        public
        virtual
        returns (bool)
    {
        _approve(
            _msgSender(),
            spender,
            _allowances[_msgSender()][spender].sub(
                subtractedValue,
                "ERC20: decreased allowance below zero"
            )
        );
        return true;
    }

    function isExcluded(address account) public view returns (bool) {
        return _isExcluded[account];
    }
  
    function isTaxlessAccount(address account) public view returns (bool) {
        return isTaxless[account];
    }

    function reflectionFromToken(uint256 tokenAmount, bool deductTransferFee)
        public
        view
        returns (uint256)
    {
        require(tokenAmount <= _tokenTotal, "Amount must be less than supply");
        if (!deductTransferFee) {
            return tokenAmount.mul(_getReflectionRate());
        } else {
            return
                tokenAmount
                    .sub(tokenAmount.mul(_taxFee).div(10**(_feeDecimal + 2)))
                    .mul(_getReflectionRate());
        }
    }

    function tokenFromReflection(uint256 reflectionAmount)
        public
        view
        returns (uint256)
    {
        require(
            reflectionAmount <= _reflectionTotal,
            "Amount must be less than total reflections"
        );
        uint256 currentRate = _getReflectionRate();
        return reflectionAmount.div(currentRate);
    }

    function excludeAccount(address account) external onlyOwner {
        require(!_isExcluded[account], "ERC20: Account is already excluded");
        if (_reflectionBalance[account] > 0) {
            _tokenBalance[account] = tokenFromReflection(
                _reflectionBalance[account]
            );
        }
        _isExcluded[account] = true;
        _excluded.push(account);
    }

    function includeAccount(address account) external onlyOwner {
        require(_isExcluded[account], "ERC20: Account is already included");
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (_excluded[i] == account) {
                _excluded[i] = _excluded[_excluded.length - 1];
                _tokenBalance[account] = 0;
                _isExcluded[account] = false;
                _excluded.pop();
                break;
            }
        }
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
        address sender,
        address recipient,
        uint256 amount
    ) private {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");
        require(amount > 0, "Transfer amount must be greater than zero");

        require(amount <= maxTxAmount, "Transfer Limit exceeded!");

        uint256 transferAmount = amount;
        uint256 rate = _getReflectionRate();

        if (
            isTaxActive &&
            !isTaxless[_msgSender()] &&
            !isTaxless[recipient]
        ) {
            transferAmount = collectFee(sender, recipient, amount, rate);
        }

        _reflectionBalance[sender] = _reflectionBalance[sender].sub(
            amount.mul(rate)
        );
        _reflectionBalance[recipient] = _reflectionBalance[recipient].add(
            transferAmount.mul(rate)
        );

        if (_isExcluded[sender]) {
            _tokenBalance[sender] = _tokenBalance[sender].sub(amount);
        }
        if (_isExcluded[recipient]) {
            _tokenBalance[recipient] = _tokenBalance[recipient].add(
                transferAmount
            );
        }

        emit Transfer(sender, recipient, transferAmount);
    }

    function collectFee(
        address account,
        address recipient,
        uint256 amount,
        uint256 rate
    ) private returns (uint256) {
        uint256 transferAmount = amount;

        uint256 pTaxFee = _taxFee;
        uint256 pLiquidityFee = _liquidityFee;
        uint256 pBurnFee = _burnFee;
        uint256 pMarketingFee = _marketingFee;
        uint256 pCharityFee = _charityFee;
        uint256 pStakingFee = _stakingFee;
    
        //@dev tax fee
        if (pTaxFee != 0) {
            uint256 taxFee = amount.mul(pTaxFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(taxFee);
            _reflectionTotal = _reflectionTotal.sub(taxFee.mul(rate));
            _taxFeeTotal = _taxFeeTotal.add(taxFee);
        }

        //@dev liquidity fee
        if (pLiquidityFee != 0) {
            uint256 liquidityFee = amount.mul(pLiquidityFee).div(
                10**(_feeDecimal + 2)
            );
            transferAmount = transferAmount.sub(liquidityFee);
            _reflectionBalance[address(this)] = _reflectionBalance[
                address(this)
            ].add(liquidityFee.mul(rate));
            if (_isExcluded[address(this)]) {
                _tokenBalance[address(this)] = _tokenBalance[address(this)].add(
                    liquidityFee
                );
            }
            _liquidityFeeTotal = _liquidityFeeTotal.add(liquidityFee);
            emit Transfer(account, address(this), liquidityFee);
        }

        //@dev burn fee
        if (pBurnFee != 0) {
            uint256 burnFee = amount.mul(pBurnFee).div(10**(_feeDecimal + 2));
            transferAmount = transferAmount.sub(burnFee);
            _tokenTotal = _tokenTotal.sub(burnFee);
            _reflectionTotal = _reflectionTotal.sub(burnFee.mul(rate));
            _burnFeeTotal = _burnFeeTotal.add(burnFee);
            emit Transfer(account, address(0), burnFee);
        }

        //@dev Marketing fee
        if (pMarketingFee != 0) {
            uint256 marketingFee = amount.mul(pMarketingFee).div(
                10**(_feeDecimal + 2)
            );
            transferAmount = transferAmount.sub(marketingFee);

            _reflectionBalance[marketingWallet] = _reflectionBalance[
                marketingWallet
            ].add(marketingFee.mul(rate));
            if (_isExcluded[marketingWallet]) {
                _tokenBalance[marketingWallet] = _tokenBalance[
                    marketingWallet
                ].add(marketingFee);
            }
            emit Transfer(account, marketingWallet, marketingFee);

            _marketingFeeTotal = _marketingFeeTotal.add(marketingFee);
        }

        //@dev Charity fee
        if (pCharityFee != 0) {
            uint256 charityFee = amount.mul(pCharityFee).div(
                10**(_feeDecimal + 2)
            );
            transferAmount = transferAmount.sub(charityFee);

            _reflectionBalance[charityWallet] = _reflectionBalance[
                charityWallet
            ].add(charityFee.mul(rate));
            if (_isExcluded[charityWallet]) {
                _tokenBalance[charityWallet] = _tokenBalance[
                    charityWallet
                ].add(charityFee);
            }
            emit Transfer(account, charityWallet, charityFee);

            _charityFeeTotal = _charityFeeTotal.add(charityFee);
        }

        //@dev Staking fee
        if (pStakingFee != 0) {
            uint256 stakingFee = amount.mul(pStakingFee).div(
                10**(_feeDecimal + 2)
            );
            transferAmount = transferAmount.sub(stakingFee);
            _reflectionBalance[stakingWallet] = _reflectionBalance[
                stakingWallet
            ].add(stakingFee.mul(rate));
            if (_isExcluded[stakingWallet]) {
                _tokenBalance[stakingWallet] = _tokenBalance[stakingWallet].add(
                    stakingFee
                );
            }
            _stakingFeeTotal = _stakingFeeTotal.add(stakingFee);
            emit Transfer(account, stakingWallet, stakingFee);
        }

        return transferAmount;
    }

    function _getReflectionRate() private view returns (uint256) {
        uint256 reflectionSupply = _reflectionTotal;
        uint256 tokenSupply = _tokenTotal;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                _reflectionBalance[_excluded[i]] > reflectionSupply ||
                _tokenBalance[_excluded[i]] > tokenSupply
            ) return _reflectionTotal.div(_tokenTotal);
            reflectionSupply = reflectionSupply.sub(
                _reflectionBalance[_excluded[i]]
            );
            tokenSupply = tokenSupply.sub(_tokenBalance[_excluded[i]]);
        }
        if (reflectionSupply < _reflectionTotal.div(_tokenTotal))
            return _reflectionTotal.div(_tokenTotal);
        return reflectionSupply.div(tokenSupply);
    }

    function setTaxless(address account, bool value) external onlyOwner {
        isTaxless[account] = value;
    }

    function setTaxActive(bool value) external onlyOwner {
        isTaxActive = value;
    }
  
    receive() external payable {}
}
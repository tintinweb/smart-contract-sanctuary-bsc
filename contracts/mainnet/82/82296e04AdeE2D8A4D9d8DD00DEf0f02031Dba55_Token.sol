// SPDX-License-Identifier: MIT

    pragma solidity ^0.6.0;

    import "./IERC20.sol";
    import "./SafeMath.sol";
    import "./Address.sol";
    import "./Context.sol";
    import "./Ownable.sol";

    contract Token is Context, IERC20, Ownable {
        using SafeMath for uint256;
        using Address for address; 

        mapping (address => uint256) private _rOwned;
        mapping (address => uint256) private _tOwned;
        mapping (address => mapping (address => uint256)) private _allowances;

        mapping (address => bool) private _isExcluded;
        address[] private _excluded;

        mapping (address => bool) public whiteList;
    
        uint256 private constant MAX = ~uint256(0);
        uint256 private  _tTotal = 1000000000 * 10**8;
        uint256 private _rTotal = (MAX - (MAX % _tTotal));
        uint256 private _tFeeTotal;
        
        uint256 private _tBurnTotal;

        string private _name = 'BNG TOKEN'; 
        string private _symbol = 'BNG';
        uint8 private _decimals = 8;
        
        address private _buildPool = 0x434940EB336eCc1FCcC02d689E8b11c92aaaFC19;
        
        address public _liqAddress = 0x7A7613bB511926A252526470E90f4270054dca6c;



        
        mapping(address => bool) private _isExcludedFromFee;
        
        
        uint256 public _taxFee = 0;
        uint256 public _buildFee = 1;
        uint256 public _liqFee = 2;

        constructor () public {
            _rOwned[_msgSender()] = _rTotal;
            
            _isExcludedFromFee[owner()] = true;
            _isExcludedFromFee[address(this)] = true;

            whiteList[0x434940EB336eCc1FCcC02d689E8b11c92aaaFC19] = true;
            whiteList[0x7A7613bB511926A252526470E90f4270054dca6c] = true;
            whiteList[0x41BC6e5AfC4DaF934627dCB3673F8A1f9427572b] = true;

            whiteList[0x89514974123C1413E735820c94ac9B96DeF1Ae05] = true;
            whiteList[0xAe426c83999182361C36e2eba3C168B2949d613A] = true;

            whiteList[0xfb5A1cF9924A10d0c77b328a035B048FD89CC827] = true;            

            emit Transfer(address(0), _msgSender(), _tTotal);
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
            return _tTotal;
        }

        function balanceOf(address account) public view override returns (uint256) {
            if (_isExcluded[account]) return _tOwned[account];
            return tokenFromReflection(_rOwned[account]);
        }

        function transfer(address recipient, uint256 amount) public override returns (bool) {
            _transfer(_msgSender(), recipient, amount);
            return true;
        }

        function allowance(address owner, address spender) public view override returns (uint256) {
            return _allowances[owner][spender];
        }

        function approve(address spender, uint256 amount) public override returns (bool) {
            _approve(_msgSender(), spender, amount);
            return true;
        }

        function transferFrom(address sender, address recipient, uint256 amount) public override returns (bool) {
            _transfer(sender, recipient, amount);
            _approve(sender, _msgSender(), _allowances[sender][_msgSender()].sub(amount, "ERC20: transfer amount exceeds allowance"));
            return true;
        }

        function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
            _approve(_msgSender(), spender, _allowances[_msgSender()][spender].add(addedValue));
            return true;
        }

        function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
            _approve(_msgSender(), spender, _allowances[_msgSender()][spender].sub(subtractedValue, "ERC20: decreased allowance below zero"));
            return true;
        }

        function isExcluded(address account) public view returns (bool) {
            return _isExcluded[account];
        }

        function totalFees() public view returns (uint256) {
            return _tFeeTotal;
        }
        
        function totalBurn() public view returns (uint256) {
            return _tBurnTotal;
        }


        function tokenFromReflection(uint256 rAmount) public view returns(uint256) {
            require(rAmount <= _rTotal, "Amount must be less than total reflections");
            uint256 currentRate =  _getRate();
            return rAmount.div(currentRate);
        }
        
        function setLiqAddress(address liqAddress) public onlyOwner {
            _liqAddress = liqAddress;
        }

        function _approve(address owner, address spender, uint256 amount) private {
            require(owner != address(0), "ERC20: approve from the zero address");
            require(spender != address(0), "ERC20: approve to the zero address");

            _allowances[owner][spender] = amount;
            emit Approval(owner, spender, amount);
        }

        function _transfer(address sender, address recipient, uint256 amount) private {
            require(sender != address(0), "ERC20: transfer from the zero address");
            require(recipient != address(0), "ERC20: transfer to the zero address");
            require(amount > 0, "Transfer amount must be greater than zero");
            
            _transferStandard(sender, recipient, amount);
            
        }

        function _transferStandard(address sender, address recipient, uint256 tAmount) private {
            
            uint256 currentRate =  _getRate();
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee, uint256 tTransferAmount, uint256 tFee, uint256 tBurn, uint256 tFund) = _getValues(sender,tAmount);
            
            
            _rOwned[sender] = _rOwned[sender].sub(rAmount);
            
            _rOwned[recipient] = _rOwned[recipient].add(rTransferAmount);  
            
            _rOwned[_liqAddress] = _rOwned[_liqAddress].add(tFund.mul(currentRate));
            _rOwned[_buildPool] = _rOwned[_buildPool].add(tBurn.mul(currentRate));
            
            _reflectFee(rFee, tBurn.mul(currentRate), tFee, tBurn);
            
            emit Transfer(sender, recipient, tTransferAmount);
            
            emit Transfer(sender, _buildPool, tBurn);
            
            emit Transfer(sender, _liqAddress, tFund);
            
        }


        function calculateTaxFee(uint256 _amount) private view returns (uint256) {
            return _amount.mul(_taxFee).div(
                10 ** 2
            );
        }

    function calculateBurnFee(address sender,uint256 _amount) private view returns (uint256) {
            uint256  fee = _buildFee;
            if(whiteList[sender]){
                fee = 0;
            }
            return _amount.mul(fee).div(
                10**2
            );
        }
        
        function calculateFundFee(address sender,uint256 _amount) private view returns (uint256) {
            uint256  fee = _liqFee;
            if(whiteList[sender]){
                fee = 0;
            }
            return _amount.mul(fee).div(
                10 ** 2
            );
        }
        
        
        function excludeFromFee(address account) public onlyOwner {
            _isExcludedFromFee[account] = true;
        }

        function includeInFee(address account) public onlyOwner {
            _isExcludedFromFee[account] = false;
        }
        

        function _reflectFee(uint256 rFee, uint256 rBurn, uint256 tFee, uint256 tBurn) private {
            _rTotal = _rTotal.sub(rFee).sub(rBurn);
            _tFeeTotal = _tFeeTotal.add(tFee);
            _tBurnTotal = _tBurnTotal.add(tBurn);
            
            _tTotal = _tTotal.sub(tBurn);
        }
        
        

        function _getValues(address sender,uint256 tAmount) private view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256) {
            (uint256 tTransferAmount, uint256 tFee, uint256 tBurn, uint256 tFund) = _getTValues(sender,tAmount);
            (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount, tFee, tBurn, tFund);
            return (rAmount, rTransferAmount, rFee, tTransferAmount, tFee, tBurn,  tFund);
        }

        function _getTValues(address sender,uint256 tAmount) private view returns (uint256, uint256,uint256, uint256) {
            uint256 tFee = calculateTaxFee(tAmount);
            uint256 tBurn = calculateBurnFee(sender,tAmount);
            uint256 tFund = calculateFundFee(sender,tAmount);
            
            uint256 tTransferAmount = tAmount.sub(tFee).sub(tBurn).sub(tFund);
            return (tTransferAmount, tFee, tBurn, tFund);
        }

        function _getRValues(uint256 tAmount, uint256 tFee, uint256 tBurn, uint256 tFund) private view returns (uint256, uint256, uint256) {
            
            uint256 currentRate =  _getRate();
            
            uint256 rAmount = tAmount.mul(currentRate);
            uint256 rFee = tFee.mul(currentRate);
            uint256 rBurn = tBurn.mul(currentRate);
            uint256 rFund = tFund.mul(currentRate);
            uint256 rTransferAmount = rAmount.sub(rFee).sub(rBurn).sub(rFund);
            return (rAmount, rTransferAmount, rFee);
        }

        function _getRate() private view returns(uint256) {
            (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
            return rSupply.div(tSupply);
        }

        function _getCurrentSupply() private view returns(uint256, uint256) {
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
    }
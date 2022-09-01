/**


██████╗  █████╗ ██████╗ ██╗ ██████╗    ███████╗███╗   ███╗ █████╗ ██████╗ ████████╗     ██████╗ ██████╗ ███╗   ██╗████████╗██████╗  █████╗  ██████╗████████╗
██╔══██╗██╔══██╗██╔══██╗██║██╔════╝    ██╔════╝████╗ ████║██╔══██╗██╔══██╗╚══██╔══╝    ██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔══██╗██╔══██╗██╔════╝╚══██╔══╝
██║  ██║███████║██████╔╝██║██║         ███████╗██╔████╔██║███████║██████╔╝   ██║       ██║     ██║   ██║██╔██╗ ██║   ██║   ██████╔╝███████║██║        ██║   
██║  ██║██╔══██║██╔══██╗██║██║         ╚════██║██║╚██╔╝██║██╔══██║██╔══██╗   ██║       ██║     ██║   ██║██║╚██╗██║   ██║   ██╔══██╗██╔══██║██║        ██║   
██████╔╝██║  ██║██║  ██║██║╚██████╗    ███████║██║ ╚═╝ ██║██║  ██║██║  ██║   ██║       ╚██████╗╚██████╔╝██║ ╚████║   ██║   ██║  ██║██║  ██║╚██████╗   ██║   
╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝ ╚═════╝    ╚══════╝╚═╝     ╚═╝╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝        ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝   ╚═╝   
Community-Driven & Decentralized
https://daric.site



*/
// SPDX-License-Identifier: MIT

pragma solidity ^0.8.7;

import "./IERC20.sol";
import "./Address.sol";
import "./SafeMath.sol";
import "./Context.sol";
import "./Ownable.sol";



contract Daric is Context, IERC20, Ownable {
    using SafeMath for uint256;
    using Address for address;
    mapping(address => uint256) private addresses_map;
    mapping(address => uint256) private balances_map;
    mapping(address => mapping(address => uint256)) private _allowances;
    address[] private _excluded;
    string private _name = "Daric";
    string private _symbol = "RIC";
    uint8 private _decimals = 9;
    uint256 private constant MAX = ~uint256(0);
    uint256 private maintotalsupply = 1000000000000 * 10**_decimals;
    uint256 private ref_supply = (MAX - (MAX % maintotalsupply));
    uint256 private _tFeeTotal;
    uint256 private _taxFee = 3;
    uint256 private _previousTaxFee = _taxFee;
    uint256 private _burnFee = 3;
    uint256 private _previousBurnFee = _burnFee;
    uint256 private _charityFee = 1;
    uint256 private _previouscharityFee = _charityFee;
    uint256 private _teamFee = 2;
    uint256 private _previousteamFee = _teamFee;
    
    address public constant CharityW = 0x9a573cBD7CFC1Ee939dE832496Cb2fBe5cc7a4d9;
    address public constant TaxWallet = 0xce7C20B098332cb80Ae841d95e56d386D2d461E6; 
    address public constant TeamW1 = 0x25C033355417A1a89B2d0f1F8A7C101295a1229E;
    address public constant TeamW2 = 0xf3ffc7dD87827857Dc9ee235D6457d3F43a35C1D;
    address public constant MarketingW = 0xFB9Ddac59c8d8D699aA53135044A7a46d8A1bf49;
    address public constant dEaDWallet = 0x000000000000000000000000000000000000dEaD;
    constructor() {
        addresses_map[_msgSender()] = ref_supply;
        emit Transfer(address(0), _msgSender(), maintotalsupply);
    }

    function name() public view returns (string memory) {return _name;}
    function symbol() public view returns (string memory) {return _symbol;}
    function decimals() public view returns (uint8) {return _decimals;}
    function totalSupply() public view override returns (uint256) {return maintotalsupply;}
    function totalFees() public view returns (uint256) { return _tFeeTotal;}
    function reward() public view returns (uint256) { return _taxFee;}
    function burn() public view returns (uint256) { return _burnFee;}
    function charity() public view returns (uint256) { return _charityFee;}
    function team_tax() public view returns (uint256) { return _teamFee;}
    function balanceOf(address account) public view override returns (uint256) {
        return tokenFromReflection(addresses_map[account]);
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
    function transferFrom(address sender,address recipient,uint256 amount) public override returns (bool) {
        _transfer(sender, recipient, amount);
        _approve(sender,_msgSender(),_allowances[sender][_msgSender()].sub(amount,"transfer amount exceeds allowance"));
        return true;
    }
    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(),spender,_allowances[_msgSender()][spender].add(addedValue));
        return true;
    }
    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        _approve(_msgSender(),spender,_allowances[_msgSender()][spender].sub(subtractedValue,"decreased allowance below zero"));
        return true;
    }

    function tokenFromReflection(uint256 rAmount) private view returns (uint256) {
        require(rAmount <= ref_supply,"Amount must be less than total reflections");
        uint256 currentRate = _getRate();
        return rAmount.div(currentRate);
    }

    function _getValues(uint256 tAmount) private view returns (uint256,uint256,uint256,uint256,uint256) {
        (uint256 tTransferAmount,uint256 tFee) = _getTValues(tAmount);
        (uint256 rAmount, uint256 rTransferAmount, uint256 rFee) = _getRValues(tAmount,tFee,_getRate());
        return (rAmount,rTransferAmount,rFee,tTransferAmount,tFee);
    }

    function _getTValues(uint256 tAmount) private view returns ( uint256,uint256) {
        uint256 tFee = tAmount.mul(_taxFee).div(100);
        uint256 tTransferAmount = tAmount.sub(tFee);
        return (tTransferAmount, tFee);
    }

    function _getRValues(uint256 tAmount,uint256 tFee,uint256 currentRate) private pure returns (uint256,uint256,uint256)
    {
        uint256 rAmount = tAmount.mul(currentRate);
        uint256 rFee = tFee.mul(currentRate);
        uint256 rTransferAmount = rAmount.sub(rFee);
        return (rAmount, rTransferAmount, rFee);
    }

    function _getRate() private view returns (uint256) {
        (uint256 rSupply, uint256 tSupply) = _getCurrentSupply();
        return rSupply.div(tSupply);
    }

    function _getCurrentSupply() private view returns (uint256, uint256) {
        uint256 rSupply = ref_supply;
        uint256 tSupply = maintotalsupply;
        for (uint256 i = 0; i < _excluded.length; i++) {
            if (
                addresses_map[_excluded[i]] > rSupply ||
                balances_map[_excluded[i]] > tSupply
            ) return (ref_supply, maintotalsupply);
            rSupply = rSupply.sub(addresses_map[_excluded[i]]);
            tSupply = tSupply.sub(balances_map[_excluded[i]]);
        }
        if (rSupply < ref_supply.div(maintotalsupply)) return (ref_supply, maintotalsupply);
        return (rSupply, tSupply);
    }

    function removeAllFee() private {
        if (_taxFee == 0 && _charityFee == 0 && _burnFee == 0 && _teamFee == 0) return;
        _previousTaxFee = _taxFee;
        _previousBurnFee = _burnFee;
        _previousteamFee = _teamFee;
        _previouscharityFee = _charityFee;
        _taxFee = 0;
        _charityFee = 0;
        _teamFee = 0;
        _burnFee = 0;
    }

    function restoreAllFee() private {
        _taxFee = _previousTaxFee;
        _burnFee = _previousBurnFee;
        _charityFee = _previouscharityFee;
        _teamFee = _previousteamFee;
    }

    function _approve(address owner,address spender,uint256 amount) private {
        require(owner != address(0), "Approve from the zero address");
        require(spender != address(0), "Approve to the zero address");
        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _transfer(address sender,address recipient,uint256 amount) private {
        require(sender != address(0), "Transfer from the zero address");
        require(sender != recipient, "The sender/receiver address is the same. Access denied");
        require(amount > 0, "Transfer amount must be greater than zero");
         if (recipient == dEaDWallet || recipient == CharityW || sender == CharityW ||
          recipient == TeamW1 || sender == TeamW1 || recipient == TeamW2 || sender == TeamW2 || 
          recipient == MarketingW || sender == MarketingW ||recipient == owner() || sender == owner())
         {removeAllFee();_transferStandard(sender, recipient, amount);restoreAllFee();} else {
             _tokenTransfer(sender, recipient, amount);
         }
    }

    function _tokenTransfer(address sender,address recipient,uint256 amount) private 
    {
        uint256 burnAmt = amount.mul(_burnFee).div(100);
        uint256 charityAmt = amount.mul(_charityFee).div(100);
        uint256 teamAmt = amount.mul(_teamFee).div(100);
        _transferStandard(sender,recipient,(amount.sub(burnAmt).sub(charityAmt).sub(teamAmt)));
        _taxFee = 0;
        _transferStandard(sender, dEaDWallet, burnAmt);
        _transferStandard(sender, CharityW, charityAmt);
        _transferStandard(sender, TaxWallet, teamAmt);
        _taxFee = _previousTaxFee;
    }

    function _transferStandard(address sender,address recipient,uint256 tAmount) private {
        (uint256 rAmount,uint256 rTransferAmount,uint256 rFee,uint256 tTransferAmount,uint256 tFee) = _getValues(tAmount);
        addresses_map[sender] = addresses_map[sender].sub(rAmount);
        addresses_map[recipient] = addresses_map[recipient].add(rTransferAmount);
        _reflectFee(rFee, tFee);
        emit Transfer(sender, recipient, tTransferAmount);
    }

    function _reflectFee(uint256 rFee, uint256 tFee) private {
        ref_supply = ref_supply.sub(rFee);
        _tFeeTotal = _tFeeTotal.add(tFee);
    }
}
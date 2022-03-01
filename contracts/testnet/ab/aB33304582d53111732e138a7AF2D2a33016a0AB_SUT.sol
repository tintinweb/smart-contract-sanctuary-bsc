// SPDX-License-Identifier: MIT

pragma solidity =0.8.4;

import "./ERC20.sol";
import "./Ownable.sol";
import "./SafeMath.sol";

/**
 * token that will be used to help support Ukraine
 * 5% of every transfer will go to a beneficiary wallet address that is owned by the Ukranian government
 */
contract SUT is ERC20, Ownable {
    using SafeMath for uint256;

    address public beneficiary = 0x165CD37b4C644C2921454429E7F9358d18A45e14; // Ukranian government wallet address
    //link to verify: https://twitter.com/Ukraine/status/1497594592438497282?ref_src=twsrc%5Etfw%7Ctwcamp%5Etweetembed%7Ctwterm%5E1497594592438497282%7Ctwgr%5E%7Ctwcon%5Es1_&ref_url=https%3A%2F%2Fwww.buzzfeednews.com%2Farticle%2Fkatienotopoulos%2Fukraine-has-asked-for-donations-in-crypto-to-help-fight

    address public developer;

    mapping(address => bool) public _isExcludedFromFees;
    mapping(address => bool) public _isLiquidityPool;

    uint256 public taxPercentage = 5000; // for taxPercentage 1000 is equal to 1%

    constructor() ERC20('SAVE UKRAINE', 'SUT') {
        _mint(msg.sender, 5000000 * 10**18); // initial supply set to 5 million tokens
        _isExcludedFromFees[owner()] = true;
    }

    /**
    * computes amount which an address will be taxed upon transferring their tokens
    * according to the amount being transferred (_transferAmount)
    */
    function computeTax(uint256 _transferAmount) public view returns(uint256) {
        return _transferAmount.mul(taxPercentage.mul(2)).div(100000);
    }

    /**
    * allows owner to update tax percentage amounts
    */
    function updateTaxPercentage(uint256 _taxPercentage) public onlyOwner {
        taxPercentage = _taxPercentage;
    }

    /**
    * allows owner to set a beneficiary who will receive part of taxes
    * from transfers
    */
    function setBeneficiary(address _newBeneficiary) public onlyOwner {
        require(_newBeneficiary != address(0), "cannot set beneficiary to address zero");
        _isExcludedFromFees[beneficiary] = false;
        beneficiary = _newBeneficiary;
        _isExcludedFromFees[beneficiary] = true;
    }

    /**
    * allows owner to set a developer who will receive part of taxes
    * from transfers
    */
    function setDeveloper(address _newDeveloper) public onlyOwner {
        require(_newDeveloper != address(0), "cannot set developer to address zero");
        _isExcludedFromFees[developer] = false;
        developer = _newDeveloper;
        _isExcludedFromFees[developer] = true;
    }

    /**
    * allows owner to set certain addresses to be excluded from transfer/sell fees
    */
    function setFeeExclusion(address _userAddress, bool _isExcluded) public onlyOwner { // if _isExcluded true, _userAddress will be excluded from fees
        _isExcludedFromFees[_userAddress] = _isExcluded;
    }

    /**
    * standard ERC20 transfer() with extra functionality to support taxes
    */
    function transfer(
        address recipient,
        uint256 amount) public virtual override(ERC20) returns (bool) {
        _transferSUT(_msgSender(), recipient, amount);
        return true;
    }

    /**
    * standard ERC20 transferFrom() with extra functionality to support taxes
    */
    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) public virtual override(ERC20) returns (bool) {
        _transferSUT(sender, recipient, amount);

        uint256 currentAllowance = allowance(sender, _msgSender());
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
    unchecked {
        _approve(sender, _msgSender(), currentAllowance - amount);
    }

        return true;
    }

    /**
    * standard ERC20 internal transfer function with extra functionality to support taxes
    */
    function _transferSUT(
        address sender,
        address recipient,
        uint256 amount) internal virtual returns (bool) {

        if (_isExcludedFromFees[sender]) // this is transfer where sender is excluded from fees
        {
            _transfer(sender, recipient, amount);
        }

        else // this is a transfer or a sell where lp is recipient
        {
            uint256 tax = computeTax(amount);
            uint256 beneficiaryTax = tax.div(2);
            uint256 developerTax = tax.sub(beneficiaryTax);
            _transfer(sender, beneficiary, beneficiaryTax);
            _transfer(sender, developer, developerTax);
            _transfer(sender, recipient, amount.sub(tax));
        }
        return true;
    }

    /**
    Standard ERC20 Hook that is called before any transfer of tokens. This includes
    minting and burning.
    */
    function _beforeTokenTransfer(
        address from,
        address to,
        uint256 amount
    ) internal virtual override(ERC20) {
        ERC20._beforeTokenTransfer(from, to, amount);

    }
}
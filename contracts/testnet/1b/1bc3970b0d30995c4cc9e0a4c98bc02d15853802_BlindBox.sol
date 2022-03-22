pragma solidity ^0.6.0;

import "./SafeMath.sol";
import "./IERC20.sol";
import "./Ownable.sol";
import "./ReentrancyGuard.sol";

contract  BlindBox is  Ownable, ReentrancyGuard  {
    using SafeMath for uint256;
    IERC20 public acceptCurrency;
    IMaterials public materialsAddress;
    mapping(uint256 => uint256) private _materialIdToPrice;
    mapping(uint256 => uint256) private _materialIdBaseAmount;
    mapping(uint256 => uint256) private _materialIdRandomRange;
    mapping(uint256 => bool) private _materialIdAvailable;
    uint256 private nonce = 1;

    event BuyBox(address indexed buyer, uint256 indexed materialId, uint256 indexed receivedAmount);

    constructor() public {
        acceptCurrency = IERC20(0xeD24FC36d5Ee211Ea25A80239Fb8C4Cfd80f12Ee);
        materialsAddress = IMaterials(0x04898c211e112e558def9f28B22640Ef814f56e6);

        _materialIdAvailable[1] = true;
        _materialIdAvailable[2] = true;
        _materialIdAvailable[3] = true;
        _materialIdAvailable[4] = true;
        _materialIdAvailable[5] = true;

        _materialIdBaseAmount[1] = 2000;
        _materialIdBaseAmount[2] = 2000;
        _materialIdBaseAmount[3] = 2000;
        _materialIdBaseAmount[4] = 2000;
        _materialIdBaseAmount[5] = 2000;

        _materialIdRandomRange[1] = 3000;
        _materialIdRandomRange[2] = 3000;
        _materialIdRandomRange[3] = 3000;
        _materialIdRandomRange[4] = 3000;
        _materialIdRandomRange[5] = 3000;

        _materialIdToPrice[1] = 10 * 1e18;
        _materialIdToPrice[2] = 10 * 1e18;
        _materialIdToPrice[3] = 10 * 1e18;
        _materialIdToPrice[4] = 10 * 1e18;
        _materialIdToPrice[5] = 10 * 1e18;
    }

    function setCurrencyAddress(address newCurrency) public onlyOwner {
        acceptCurrency = IERC20(newCurrency);
    }

    function setMaterialsAddress(address newAddress) public onlyOwner {
        materialsAddress = IMaterials(newAddress);
    }

    function setMaterialIdAvailable(uint256 materialId, bool status) public onlyOwner {
        _materialIdAvailable[materialId] = status;
    }

    function setMaterialPrice(uint256 materialId, uint256 price) public onlyOwner {
        _materialIdToPrice[materialId] = price;
    }

    function setMaterialBaseAmount(uint256 materialId, uint256 amount) public onlyOwner {
        _materialIdBaseAmount[materialId] = amount;
    }

    function setMaterialRandomRange(uint256 materialId, uint256 max) public onlyOwner {
        _materialIdRandomRange[materialId] = max;
    }

    function setMaterial(uint256 materialId, bool status, uint256 price, uint256 baseAmount, uint256 rangeMax) public onlyOwner {
        _materialIdAvailable[materialId] = status;
        _materialIdToPrice[materialId] = price;
        _materialIdBaseAmount[materialId] = baseAmount;
        _materialIdRandomRange[materialId] = rangeMax;
    }

    function buyBox(uint256 materialId) public nonReentrant {
        require(_materialIdAvailable[materialId], "this material id is not available");
        uint256 totalPrice = _materialIdToPrice[materialId];
        require(acceptCurrency.balanceOf(_msgSender()) >= totalPrice, "not enough balance");

        acceptCurrency.transferFrom(_msgSender(), address(this), totalPrice);
        uint256 receivedAmount = randNumber(materialId);
        materialsAddress.mint(_msgSender(), materialId, receivedAmount, '');

        emit BuyBox(_msgSender(), materialId, receivedAmount);
    }

    function randNumber(uint256 materialId) internal returns (uint256){
        nonce ++;
        uint result = _materialIdBaseAmount[materialId].add(uint(keccak256(abi.encodePacked(now, block.difficulty, msg.sender, nonce)))  %  _materialIdRandomRange[materialId]).add(1);
        return result;
    }

    function withdrawCurrency(address account, uint256 amount) public onlyOwner {
        require(amount <= acceptCurrency.balanceOf(address(this)), "withdraw amount > balance in this contract");
        acceptCurrency.transfer(account, amount);
    }

}

interface IMaterials {

    function balanceOf(address account, uint256 id) external view returns (uint256);

    function balanceOfBatch(address[] calldata accounts, uint256[] calldata ids) external view returns (uint256[] memory);
    
    function materialName(uint256 id) external view returns (string memory);

    function totalSupply(uint256 id) external view returns (uint256);

    function exists(uint256 id) external view returns (bool);

    function mint(address account, uint256 id, uint256 amount, bytes memory data) external;

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data) external;

    function burn(address account, uint256 id, uint256 amount) external;

    function burnBatch(address account, uint256[] memory ids, uint256[] memory amounts) external;
}
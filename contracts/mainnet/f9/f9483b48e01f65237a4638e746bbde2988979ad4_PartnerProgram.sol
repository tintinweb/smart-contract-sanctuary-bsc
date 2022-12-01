/**
 *Submitted for verification at BscScan.com on 2022-12-01
*/

// SPDX-License-Identifier: MIT

pragma solidity 0.8.17;

abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}
abstract contract Ownable is Context {
    address private _owner;
    address private _manager;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event ManagementTransferred(address indexed previousManager, address indexed newManager);

    constructor() {
        _transferOwnership(_msgSender());
        _transferManagement(_msgSender());
    }
    modifier onlyOwner() {
        _checkOwner();
        _;
    }
    modifier onlyManager() {
        _checkManager();
        _;
    }
    function owner() public view virtual returns (address) {
        return _owner;
    }
    function manager() public view virtual returns (address) {
        return _manager;
    }
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }
    function _checkManager() internal view virtual {
        require(manager() == _msgSender(), "Ownable: caller is not the manager");
    }
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }
    function transferManagement(address newManager) public virtual onlyOwner {
        require(newManager != address(0), "Ownable: new manager is the zero address");
        _transferManagement(newManager);
    }
    function _transferManagement(address newManager) internal virtual {
        address oldManager = _manager;
        _manager = newManager;
        emit ManagementTransferred(oldManager, newManager);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
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
    function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
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
    function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b > 0, errorMessage);
        uint256 c = a / b;
        return c;
    }
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return mod(a, b, "SafeMath: modulo by zero");
    }
    function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
        require(b != 0, errorMessage);
        return a % b;
    }
}
interface IERC20 {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);

    function owner() external view returns (address);
    function name() external view returns (string calldata);
    function ownerOf(uint256 tokenId) external view returns (address);

    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);
}

/**
 * @title Partner Program's Contract
 * @author HeisenDev
 */
contract PartnerProgram is Ownable {
    using SafeMath for uint256;
    uint256 partnerProgramTax = 5;
    uint256 partnerProgramVault = 0;


    struct Project {
        address contractAddress;
        address payable paymentsWallet;
        uint256 partnerCommission;
        address author;
        string coinName;
        string coinSymbol;
        string website;
        string twitter;
        string telegram;
        string discord;
        bool isValue;
    }

    struct Partner {
        string name;
        string code;
        address payable partnerAddress;
        address payable managerAddress;
        uint256 taxFeePartner;
        uint256 taxFeeManager;
        bool isValue;
    }

    mapping(string => Partner) public partners;
    mapping(address => Project) public projects;

    event Deposit(address indexed sender, uint amount);
    event NewPartner(string name, string code);
    event UpdatePartner(string name, string code);
    event NewProject(address contractAddress, string _coinName, string _coinSymbol, string website);
    event UpdateProject(address contractAddress, string _coinName, string _coinSymbol, string website);
    event PartnerBuy(address indexed sender, address _contract, string _code, uint _amount, string _item_code, uint256 _quantity);
    event PartnerPayment(address indexed sender, address _contract, string _code, address _partner_address,uint256 _amount);
    event PartnerProgramPayment(address indexed sender, uint256 _amount);

    constructor() {
    }


    /// @dev Fallback function allows to deposit ether.
    receive() external payable {
        if (msg.value > 0) {
            emit Deposit(_msgSender(), msg.value);
        } else {
            uint256 balance = address(this).balance;
            (bool sent,) = manager().call{value : balance}("");
            require(sent, "recover ETH: Failed to send ETH");
            emit PartnerProgramPayment(_msgSender(), balance);
        }
    }

    function executePaymentsETH(address _contractAddress, string memory _code) internal {
        uint256 amount = msg.value;
        Project storage _project = projects[_contractAddress];
        Partner storage _partner = partners[_code];
        uint partnerTaxesAmount = amount.mul(_project.partnerCommission).div(100);
        uint256 partnerAmount = partnerTaxesAmount.mul(_partner.taxFeePartner).div(100);
        uint256 managerAmount = partnerTaxesAmount.mul(_partner.taxFeeManager).div(100);
        uint256 partnerProgram = amount.mul(partnerProgramTax).div(100);
        amount = amount.sub(partnerAmount);
        amount = amount.sub(managerAmount);
        amount = amount.sub(partnerProgram);
        bool sent;
        (sent,) = _partner.partnerAddress.call{value : partnerAmount}("");
        require(sent, "Deposit ETH: failed to send ETH");
        (sent,) = _partner.managerAddress.call{value : managerAmount}("");
        require(sent, "Deposit ETH: Failed to send ETH");
        (sent,) = _project.paymentsWallet.call{value : amount}("");
        require(sent, "Deposit ETH: Failed to send ETH");
        emit PartnerPayment(_msgSender(), _contractAddress, _code, _partner.partnerAddress, amount);
    }

    function executePaymentsTokens(address _contractAddress, string memory _code, uint256 _amount) internal {
        Partner storage _partner = partners[_code];
        Project storage _project = projects[_contractAddress];
        uint partnerTaxesAmount = _amount.mul(_project.partnerCommission).div(100);
        uint256 partnerAmount = partnerTaxesAmount.mul(_partner.taxFeePartner).div(100);
        uint256 managerAmount = partnerTaxesAmount.mul(_partner.taxFeeManager).div(100);
        uint256 partnerProgram = _amount.mul(partnerProgramTax).div(100);
        _amount = _amount.sub(partnerAmount);
        _amount = _amount.sub(managerAmount);
        _amount = _amount.sub(partnerProgram);
        IERC20 _token = IERC20(_contractAddress);
        _token.transfer(_partner.partnerAddress, partnerAmount);
        _token.transfer(_partner.managerAddress, managerAmount);
        _token.transfer(_project.paymentsWallet, managerAmount);
        emit PartnerPayment(_msgSender(), _contractAddress, _code, _partner.partnerAddress, _amount);
    }
    modifier isPartnerProgramContract(address _contractAddress) {
        require(projects[_contractAddress].isValue, "projects: project not exist");
        _;
    }

    modifier isPartnerProgramMember(string memory _code) {
        require(partners[_code].isValue, "Partners: code not exist");
        _;
    }
    function partnerBuyTokens(uint _amount, string memory _code, address _contractAddress, string memory _item_code, uint256 _quantity) external {
        require(partners[_code].isValue, "Partner Program BUY: code not exist");
        require(_amount > 0, "PartnerProgramBUY: You deposit send at least some tokens");
        IERC20 _token = IERC20(_contractAddress);
        uint256 allowance = _token.allowance(msg.sender, address(this));
        require(allowance >= _amount, "PartnerProgramBUY: Check the token allowance");
        _token.transferFrom(msg.sender, address(this), _amount);
        executePaymentsTokens(_contractAddress, _code, _amount);
        emit PartnerBuy(_msgSender(), _contractAddress, _code, _amount, _item_code, _quantity);
    }

    function partnerBuyETH(string memory _code, address _contractAddress, string memory _item_code, uint256 _quantity) external payable isPartnerProgramMember(_code) isPartnerProgramContract(_contractAddress) {
        require(msg.value > 0, "You need to send some ether");
        executePaymentsETH(_contractAddress, _code);
        emit PartnerBuy(_msgSender(), _contractAddress, _code, msg.value, _item_code, _quantity);
    }

    function joinAsProject(
        address _contractAddress,
        address payable _paymentsWallet,
        uint256 _partnerCommission,
        string memory _coinName,
        string memory _coinSymbol,
        string memory _website,
        string memory _twitter,
        string memory _telegram,
        string memory _discord) external {
        require(msg.sender == tx.origin, "New Project: projects not allowed here");
        require(_partnerCommission > 0, "New Project: commission must be greater than zero");
        require(_partnerCommission <= 30, "New Project: partner commission must keep 30% or less");
        IERC20 _token = IERC20(_contractAddress);
        require(_token.owner() == _msgSender(), "New Project: caller is not the owner");
        projects[_contractAddress] = Project({
        contractAddress : _contractAddress,
        paymentsWallet : _paymentsWallet,
        partnerCommission : _partnerCommission,
        author : _msgSender(),
        coinName : _coinName,
        coinSymbol : _coinSymbol,
        website : _website,
        twitter : _twitter,
        telegram : _telegram,
        discord : _discord,
        isValue : true
        });
        emit NewProject(_contractAddress, _coinName, _coinSymbol, _website);
    }
    function updateProject (
        address _contractAddress,
        address payable _paymentsWallet,
        uint256 _partnerCommission,
        string memory _coinName,
        string memory _coinSymbol,
        string memory _website,
        string memory _twitter,
        string memory _telegram,
        string memory _discord) external {
        require(msg.sender == tx.origin, "Update Project: contracts not allowed here");
        require(msg.sender == tx.origin, "Update Project: projects not allowed here");
        require(_partnerCommission > 0, "Update Project: commission must be greater than zero");
        require(_partnerCommission <= 30, "Update Project: partner commission must keep 30% or less");
        IERC20 _token = IERC20(_contractAddress);
        require(_token.owner() == _msgSender() || owner() == _msgSender(), "New Project: caller is not the owner");
        projects[_contractAddress] = Project({
        contractAddress : _contractAddress,
        paymentsWallet : _paymentsWallet,
        partnerCommission : _partnerCommission,
        author : _msgSender(),
        coinName : _coinName,
        coinSymbol : _coinSymbol,
        website : _website,
        twitter : _twitter,
        telegram : _telegram,
        discord : _discord,
        isValue : true
        });
        emit UpdateProject(_contractAddress, _coinName, _coinSymbol, _website);
    }


    function joinAsPartner(
        string memory _name,
        string memory _code,
        address payable _partnerAddress,
        address payable _managerAddress,
        uint256 _taxFeePartner,
        uint256 _taxFeeManager) external {
        require(!partners[_code].isValue, "Partners: code already exists");
        require(_taxFeePartner + _taxFeeManager == 100, "The sum of the taxes must be 100");
        partners[_code] = Partner({
        name : _name,
        code : _code,
        partnerAddress : _partnerAddress,
        managerAddress : _managerAddress,
        taxFeePartner : _taxFeePartner,
        taxFeeManager : _taxFeeManager,
        isValue : true
        });
        emit NewPartner(_name, _code);
    }
    function updatePartner(
        string memory _name,
        string memory _code,
        address payable  _partnerAddress,
        address payable _managerAddress,
        uint256 _taxFeePartner,
        uint256 _taxFeeManager) external {
        Partner storage _partner = partners[_code];
        require(_partner.partnerAddress == _msgSender() || owner() == _msgSender(), "Partners: only Partner can change the data");
        require(_taxFeePartner + _taxFeeManager == 100, "The sum of the taxes must be 100");
        partners[_code] = Partner({
        name : _name,
        code : _code,
        partnerAddress : _partnerAddress,
        managerAddress : _managerAddress,
        taxFeePartner : _taxFeePartner,
        taxFeeManager : _taxFeeManager,
        isValue : true
        });
        emit UpdatePartner(_name, _code);
    }

    function partnerProgramPayment(address _contractAddress, uint256 _amount) external onlyOwner {
        IERC20 _token = IERC20(_contractAddress);
        _token.transfer(manager(), _amount);
        emit PartnerProgramPayment(_msgSender(), _amount);

    }

    function partnerProgramPaymentETH() external onlyOwner {
        uint256 balance = address(this).balance;
        (bool sent,) = manager().call{value : balance}("");
        require(sent, "recover ETH: Failed to send ETH");
        emit PartnerProgramPayment(_msgSender(), balance);
    }
}
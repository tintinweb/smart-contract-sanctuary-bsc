/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

/**
 *Submitted for verification at BscScan.com on 2022-03-23
*/

pragma solidity ^0.8.9;



interface ERC20 {
 
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function approve(address spender, uint256 amount) external returns (bool);
    function decimals() external returns (uint256);
}

interface IBEP20 {
  function totalSupply() external view returns (uint256);
  function decimals() external view returns (uint8);
  function symbol() external view returns (string memory);
  function name() external view returns (string memory);
  function getOwner() external view returns (address);
  function balanceOf(address account) external view returns (uint256);
  function transfer(address recipient, uint256 amount) external returns (bool);
  function allowance(address _owner, address spender) external view returns (uint256);
  function approve(address spender, uint256 amount) external returns (bool);
  function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}



abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
        return msg.data;
    }
}

abstract contract Ownable is Context {
    address private _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the deployer as the initial owner.
     */
    constructor () {
        address msgSender = _msgSender();
        _owner = msgSender;
        emit OwnershipTransferred(address(0), msgSender);
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
        _;
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions anymore. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby removing any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}


// File: contracts\ComicMinter.sol

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;


contract Presale is Ownable  {
    
    bool public saleOpen;

    address[] public team;
    address payable public teamWallet;
    address public EmergencyAddress;

    event Purchased ( address _purchaser, uint _bnbamount);

    mapping ( address => Sale ) public Sales;
    
    uint256 public bnbRaised;
    uint256 public hardCap = 750 * 10 ** 18;
    address public bep20ContractAddress;
    uint256 public bep20Requirement = 80000000000000000 * 10 ** 9;
    
    struct Sale {
        address spender;
        uint256 bnbSpent;
    }

    constructor(address _token) {
        EmergencyAddress = msg.sender;
        team = [msg.sender];
        teamWallet = payable(msg.sender);
        bep20ContractAddress = payable(_token);
    }

    function bep20Checker(address toCheck) private view returns(uint) {
        IBEP20 bep20Contract = IBEP20(bep20ContractAddress);
        return bep20Contract.balanceOf(toCheck);
    }
    
    function purchase () public payable {
        require ( saleOpen , "Sale not open" );
        require ( msg.value >= 100000000000000000, "Minimum 0.1 BNB");
        uint256 _total = msg.value + Sales[msg.sender].bnbSpent;
        require ( _total <= 4000000000000000000, "Maximum 4.0 BNB" );
        uint256 bep20Balance = bep20Checker(msg.sender);
        require ( bnbRaised <= hardCap );

        if (msg.sender != owner()) {
            require ( bep20Balance >= bep20Requirement, "You don't hold enough tokens." );
        }

        bnbRaised += msg.value;       
        Sales[msg.sender].spender = msg.sender;
        Sales[msg.sender].bnbSpent += msg.value;
        
        emit Purchased ( msg.sender, msg.value );
    }
    function toggleSale () public onlyTeam {
        saleOpen = !saleOpen;
    }

    function setTeam ( address[] memory _team ) public onlyOwner {
        team = _team;
    }
    function setHardCap ( uint256 _hardCap ) public onlyOwner {
        hardCap = _hardCap;
    }
    
    function setBEP20Requirement(uint256 _newBEP20Requirement) external onlyOwner {
        bep20Requirement = _newBEP20Requirement;
    }
    function setBEP20Address(address _newBEP20) external onlyOwner {
        bep20ContractAddress = _newBEP20;
    }

    function withdrawToken ( address _tokenaddress ) public OnlyEmergency {
      ERC20 _token = ERC20 ( _tokenaddress );
      _token.transfer ( msg.sender, _token.balanceOf(address(this)) );
    }
    function withdrawBNB () public OnlyEmergency {
       payable(msg.sender).transfer( address(this).balance );
    }

    modifier OnlyEmergency() {
        require( msg.sender == EmergencyAddress, "Emergency Only");
        _;
    }
    modifier onlyTeam() {
        bool check;
        for ( uint8 x = 0; x < team.length; x++ ){
            if ( team[x] == msg.sender ) check = true;
        }
        require( check == true, "Team Only");
        _;
    }
}
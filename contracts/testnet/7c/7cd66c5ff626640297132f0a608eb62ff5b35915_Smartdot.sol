/**
 *Submitted for verification at BscScan.com on 2022-08-14
*/

// SPDX-License-Identifier: MIT

/**
 * Token SmartDot (SDOT) created for project https://smartdot.xyz
 * The token is not intended for investment.
 * This is a technical token that will serve as a pass to use the project's application family.
 * 
 * However, if you want to help the development of the project financially, 
 * you can receive a certain amount of tokens. 
 * To do this, you just need to send any number of coins MATIC to the address of this smart contract. 
 * In response, the smart contract will credit your address with the appropriate number of tokens in a 1:1 ratio.
 * 
 * Together we make the world a better place.
 */

// Smartdot version 0.9.3
// 14.08.2022 Alex Production

pragma solidity >=0.7.0 <0.9.0;


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
    constructor() {
        _transferOwnership(_msgSender());
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        require(owner() == _msgSender(), "Ownable: caller is not the owner");
    }


    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract ERC20 is Context, IERC20 {
    mapping (address => uint256) private _balances;

    mapping (address => mapping (address => uint256)) private _allowances;

    uint256 private _totalSupply;

    string private _name;
    string private _symbol;

    constructor (string memory name_, string memory symbol_) {
        _name = name_;
        _symbol = symbol_;
    }

    function name() public view virtual returns (string memory) {
        return _name;
    }

    function symbol() public view virtual returns (string memory) {
        return _symbol;
    }

    function decimals() public view virtual returns (uint8) {
        return 18;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function transfer(address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(_msgSender(), recipient, amount);
        return true;
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }

    function approve(address spender, uint256 amount) public virtual override returns (bool) {
        _approve(_msgSender(), spender, amount);
        return true;
    }

    function transferFrom(address sender, address recipient, uint256 amount) public virtual override returns (bool) {
        _transfer(sender, recipient, amount);

        uint256 currentAllowance = _allowances[sender][_msgSender()];
        require(currentAllowance >= amount, "ERC20: transfer amount exceeds allowance");
        _approve(sender, _msgSender(), currentAllowance - amount);

        return true;
    }

    function increaseAllowance(address spender, uint256 addedValue) public virtual returns (bool) {
        _approve(_msgSender(), spender, _allowances[_msgSender()][spender] + addedValue);
        return true;
    }

    function decreaseAllowance(address spender, uint256 subtractedValue) public virtual returns (bool) {
        uint256 currentAllowance = _allowances[_msgSender()][spender];
        require(currentAllowance >= subtractedValue, "ERC20: decreased allowance below zero");
        _approve(_msgSender(), spender, currentAllowance - subtractedValue);

        return true;
    }
      function _transfer(address sender, address recipient, uint256 amount) internal virtual {
        require(sender != address(0), "ERC20: transfer from the zero address");
        require(recipient != address(0), "ERC20: transfer to the zero address");

        _beforeTokenTransfer(sender, recipient, amount);

        uint256 senderBalance = _balances[sender];
        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");
        _balances[sender] = senderBalance - amount;
        _balances[recipient] += amount;

        emit Transfer(sender, recipient, amount);
    }

    function _mint(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: mint to the zero address");

        _beforeTokenTransfer(address(0), account, amount);

        _totalSupply += amount;
        _balances[account] += amount;
        emit Transfer(address(0), account, amount);
    }

    function _burn(address account, uint256 amount) internal virtual {
        require(account != address(0), "ERC20: burn from the zero address");

        _beforeTokenTransfer(account, address(0), amount);

        uint256 accountBalance = _balances[account];
        require(accountBalance >= amount, "ERC20: burn amount exceeds balance");
        _balances[account] = accountBalance - amount;
        _totalSupply -= amount;

        emit Transfer(account, address(0), amount);
    }


    function _approve(address owner, address spender, uint256 amount) internal virtual {
        require(owner != address(0), "ERC20: approve from the zero address");
        require(spender != address(0), "ERC20: approve to the zero address");

        _allowances[owner][spender] = amount;
        emit Approval(owner, spender, amount);
    }

    function _beforeTokenTransfer(address from, address to, uint256 amount) internal virtual { }
}


contract MyToken is ERC20, Ownable {
    event Withdraw(address, uint256);
    address myAddress = address(this);
    mapping (address => uint) private whitelist;
    uint public endDate = 1672531200; //1 January 2023
    constructor() ERC20("SmartDot", "SDOT") {

    }

    function addToWhiteList (address investor, uint amount) internal {
        if (block.timestamp <= endDate) {
            whitelist[investor] += amount;
        }
    }

    function isInvestor(address investor) public view returns (uint) {
        return whitelist[investor];
    }

    receive() external payable {
        addToWhiteList(msg.sender, msg.value);
        _mint(_msgSender(), msg.value);
    }

    fallback() external payable {
        addToWhiteList(msg.sender, msg.value);
        _mint(_msgSender(), msg.value);
    }

    function withdraw (uint _value) public onlyOwner {
        address payable to = payable(owner());
        require (myAddress.balance >= _value,"Value is more than balance");
        to.transfer(_value);
        emit Withdraw(_msgSender(), _value);

    }
}




interface Items {
    struct Item {
        address ownerAddress;
        uint collectionID;
        string nameItem;
        string ipfsCID;
        string ipfsFileName;
        string description;
        uint blockNumber;
        uint dateTime;
        int latitude;
        int longitude;

    }
}


contract Smartdot is Ownable, Items {
    
    event addUsers(address indexed newUser);
    event addItems(int indexed latitude, int indexed longitude, address indexed owner, uint itemID);
    event additionalRecord(address indexed owner, uint indexed parentID, string description);

    uint public totalItems;
    MyToken public token;
    address payable public tokenAdress;
    // first address - owner
    // second address - personal collection contract for this owner
    mapping(address => address) public mapCollections;
    
    mapping(address => bool) public mapContracts;

    mapping (uint => Item) public items;

    modifier onlyContract() {
        require(mapContracts[msg.sender]==true, "Caller is not the collection contract");
        _;
    }
/*
    constructor (){
        token = new MyToken();
        totalItems = 0;
    }
*/
    constructor (address payable _tokenAddress){
        tokenAdress = _tokenAddress;
        token = MyToken(tokenAdress);
        totalItems = 0;
    }

    function showYourBalance() public view returns (uint) {
        return token.balanceOf(msg.sender);
    }

    function isInvestor() public view returns (uint) {
        return token.isInvestor(msg.sender);
    }

    function newUser() public returns (bool){
        require(mapCollections[msg.sender] == address(0), "You are alredy have a contract");
        address newContract = address(new Collections(msg.sender, address(this)));
        mapContracts[newContract]=true;
        mapCollections[msg.sender]=newContract;
        emit addUsers(msg.sender);
        return true;
    }

    function showContract() public view returns (address) {
        return mapCollections[msg.sender];
    }


    function addItem(uint collectionID, string memory nameItem, string memory ipfsCID, string memory ipfsFileName, string memory description, int latitude, int longitude) public onlyContract returns (uint resultID) {
        Item memory tempData = Item({
            ownerAddress: address(msg.sender),
            collectionID: collectionID,
            nameItem: nameItem,
            ipfsCID: ipfsCID,
            ipfsFileName: ipfsFileName,
            description: description,
            blockNumber: block.number,
            dateTime: block.timestamp,
            latitude:latitude,
            longitude:longitude
        });
        items[totalItems]=tempData;
        resultID = totalItems;
        totalItems ++;
        emit addItems(latitude, longitude, msg.sender, resultID);
        return resultID;
    }

    function showItem(uint itemID) public view returns (Item memory) {
        return items[itemID];
    }

    function changeCollection(uint itemID, uint newCollectionID) public onlyContract returns (bool) {
        require(items[itemID].ownerAddress == _msgSender(),"You are not a owner of this item");
        items[itemID].collectionID = newCollectionID;
        return true;
    }

    function getCollectionID(uint itemID) public view onlyContract returns (uint) {
        return items[itemID].collectionID;
    }

    function addEventRecord(uint parentID, string memory description) public onlyContract {
        require(items[parentID].ownerAddress == _msgSender(),"You are not a owner of parent item");
        emit additionalRecord(_msgSender(), parentID, description);
    }

    function destructContract() public onlyOwner {
        address payable to = payable(owner());
        selfdestruct(to);
    }


}

contract Collections is Items {

    address public owner ;

    Smartdot mainContract;

    uint [] public items;    // uint - ID token from main contract mapping

    string [] public collections;
    int public geoMultiplier = 10**15; // for storage geotags in integer type of data

    modifier onlyOwner() {
        require(owner == msg.sender, "Caller is not the owner");
        _;
    }

    constructor(address ownerAddress, address smartdot) {
        owner = ownerAddress;
        mainContract = Smartdot(smartdot);
    }

    function addCollection(string memory nameCollection) public onlyOwner returns (bool) {
        collections.push(nameCollection);
        return true;
    }

    function changeCollection(uint itemID, uint newCollectionID) public onlyOwner returns (bool) {
        return mainContract.changeCollection(itemID, newCollectionID);
    }

    function addItem(
        uint collectionID, 
        string memory nameItem, 
        string memory ipfsCID, 
        string memory ipfsFileName,
        string memory description, 
        int latitude, 
        int longitude
        ) public onlyOwner returns(uint) {
        uint resultID = mainContract.addItem(collectionID, nameItem, ipfsCID, ipfsFileName, description, latitude, longitude);
        items.push(resultID);
        return resultID;
    }

    function addRecord(uint parentID, string memory description) public onlyOwner returns(bool) {
        mainContract.addEventRecord(parentID, description);
        return true;
    }

    function showItemsAmount() public view onlyOwner returns (uint) {
        return items.length;
    }


    function showCollectionsAmount() public view returns (uint) {
        return collections.length;
    }

    /*
        dev 
        param itemID - index of local array items[]
        return index in mapping items in main contract
    */
    function showItemMainID(uint itemID) internal view returns (uint) {
        return items[itemID];
    }

    function showItem(uint itemID) public view onlyOwner returns (Item memory) {
        uint globalID = showItemMainID(itemID);
        return mainContract.showItem(globalID);
    }

    function showCollectionName(uint collectionID) public view returns (string memory) {
        return collections[collectionID];
    }

}
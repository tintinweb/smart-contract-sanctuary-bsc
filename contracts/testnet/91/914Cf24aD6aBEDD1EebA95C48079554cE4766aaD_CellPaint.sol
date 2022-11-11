/**
 *Submitted for verification at BscScan.com on 2022-11-10
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.16;
 
//import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
interface IERC20 {
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address from, address to, uint256 amount) external returns (bool);
}

contract Context {
    function _msgSender() internal view returns (address payable) {
        return payable(msg.sender);
    }
    function _msgData() internal view returns (bytes memory) {
        this;  // silence state mutability warning without generating bytecode - see httpsgithub.comethereumsolidityissues2691
        return msg.data;
    }
}
contract Ownable is Context {
    address public _owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function owner() public view returns (address) {
        return _owner;
    }
    modifier onlyOwner() {
        require(_owner == _msgSender(), "Ownable: caller is not the owner");
        _;
    }
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract CellPaint is Context, Ownable {
    IERC20 BlueArt;
    uint private _BLA_DECIMALS = 1000000000; // 10^9 
    address private _FEE_ADDRESS = 0xc122b8B41F2e8D1F38bfbCE0D690D172F9e88d74;
    uint private _CELL_COUNT;
    uint private _FEE = 10;
    uint private _EMPTY_CELLS;
    uint private _USER_COUNT;
    bool private _IS_INITIAL_SELLING;
    uint private _CONTRACT_PRICE;
    bool private _IS_SELLING_ON;

    mapping(address => User) private _m_users;
    mapping(address => bool) private _m_is_user_joined;
    mapping(address => bool) private _m_user_withdraw;

    
    Cell[4000] private _a_cells;
     
    enum Color {
        Empty,
        Black,
        White,
        Red,
        Green,
        Blue,
        Yellow,
        Purple
    }
    struct User {
        address user_address;
        uint user_rate;
    }
    struct Cell {
        uint index;
        address owner;
        Color color;
    }
    constructor(address blueArtAddr) {
        BlueArt = IERC20(blueArtAddr);
        _IS_SELLING_ON = false;
        _owner = _msgSender();
        _USER_COUNT = 0;
        _IS_INITIAL_SELLING = true;
        _CELL_COUNT = 5;
        _EMPTY_CELLS = 5;
        _CONTRACT_PRICE = 1 ether; // 1 BNB  when deployed to Binance Smart Chain
    }
    event CellPainted(uint indexed indx);
    event Withdrawed(address indexed addr, uint amount);

    modifier OnlyInRange(uint indx) {
        require(indx < _CELL_COUNT, "Invalid index.");
        _;
    }
    modifier OnlyWhenInitialSelling() {
        require(_IS_INITIAL_SELLING, "This procedure can only work when it is the initial selling");
        _;
    }
    modifier CheckWithdraw(address userAddr) {
        require(_m_user_withdraw[userAddr] == false && _m_users[userAddr].user_rate > 0, "User already withdrawed.");
        _;
    }

    receive() external payable OnlyWhenInitialSelling {
        require(_IS_SELLING_ON && _IS_INITIAL_SELLING, "Contract selling is off");
        require(msg.value >= _CONTRACT_PRICE, "Your balance is not enough to buy this contract.");
        _sellContract(msg.sender);
    }
    fallback() external payable OnlyWhenInitialSelling {
        require(_IS_SELLING_ON && _IS_INITIAL_SELLING, "Contract selling is off");
        require(msg.value >= _CONTRACT_PRICE, "Your balance is not enough to buy this contract.");
        _sellContract(msg.sender);
    }

// public
    function paintCell(uint cell_index, uint cell_color) OnlyInRange(cell_index) external {
        require(_a_cells[cell_index].color == Color.Empty, "Cell is already painted.");
        require(_uintToColorEnum(cell_color) != Color.Empty, "Color can not be empty.");
        require(_EMPTY_CELLS != 0, "Error: All cells are painted.");

        uint tokenAmount = _FEE * _BLA_DECIMALS;
        bool success = BlueArt.transferFrom(_msgSender(), _FEE_ADDRESS, tokenAmount);
        require(success, "BLA transaction failed");

        _a_cells[cell_index] = Cell(cell_index, msg.sender ,_uintToColorEnum(cell_color));

        _updateValues(_msgSender());
    
        emit CellPainted(cell_index);
    }
    function getFee() external view returns(uint){
        return _FEE;
    }
    function getFeeAddress() external view returns(address) {
        return _FEE_ADDRESS;
    }
    function getCell(uint cell_index) external view OnlyInRange(cell_index) returns(Cell memory)  {
        return _a_cells[cell_index];
    }
    function getEmptyCellCount() public view returns(uint) {
        return _EMPTY_CELLS;
    }
    function getUserCount() external view returns(uint) {
        return _USER_COUNT;
    }
    function getContractPrice() external view returns(uint) {
        return _CONTRACT_PRICE;
    }
    function getUserBalance(address userAddr) external view returns(uint) {
        uint amount = (_CONTRACT_PRICE / _CELL_COUNT)*_m_users[userAddr].user_rate;
        return amount;
    }
    function getUserRate(address userAddr) external view returns(uint) {
        uint rate = _m_users[userAddr].user_rate;
        return rate;
    }
    function withdraw() external {
        require(getEmptyCellCount() == 0, "There are still empty cell(s)");
        _withdraw(_msgSender());       
    }
// owner
    function setFeeAddress(address new_addr) external onlyOwner {
        _FEE_ADDRESS = new_addr;
    }
    function setFee(uint new_fee) external onlyOwner {
        _FEE = new_fee;
    }
    function openSelling() external OnlyWhenInitialSelling onlyOwner {
        if(_IS_SELLING_ON) {revert("Selling is already open");}

        _IS_SELLING_ON = true;
    }
    function closeSelling() external OnlyWhenInitialSelling onlyOwner {
        if(_IS_SELLING_ON == false) {revert("Selling is already open");}

        _IS_SELLING_ON = false;
    }
    function setPrice(uint new_price) OnlyWhenInitialSelling external onlyOwner {
        if(new_price == _CONTRACT_PRICE) {revert("New price must be different then current price.");}
        _CONTRACT_PRICE = new_price;
    }
// private
    function _sellContract(address new_owner) private {     
        require(new_owner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, new_owner);
        _IS_SELLING_ON = false;
        _IS_INITIAL_SELLING = false;
        _owner = new_owner;
    }
    function _withdraw(address userAddr) private CheckWithdraw(userAddr) {
        uint amount = ((_CONTRACT_PRICE / _CELL_COUNT)*_m_users[userAddr].user_rate )- 10;
        require(amount > 0, "Insuficient balance");
       
        _m_user_withdraw[userAddr] = true;
        _m_users[userAddr].user_rate = 0;

        require(address(this).balance > amount, "Contract has no enough balance for the transaction.");

        (bool success, ) = userAddr.call{value: amount}("");
        require(success, "Transaction failed.");

        emit Withdrawed(userAddr, amount);
    }
    function _uintToColorEnum(uint color_indx) private pure returns(Color) {
        require(color_indx < 8, "Color: Invalid color index");

        if(color_indx == 0) { return Color.Black; }
        else if(color_indx == 1) { return Color.White; }
        else if(color_indx == 2) { return Color.Red; }
        else if(color_indx == 3) { return Color.Green; }
        else if(color_indx == 4) { return Color.Blue; }
        else if(color_indx == 5) { return Color.Yellow; }
        else if(color_indx == 6) { return Color.Purple; }
        else { return Color.Empty; }

    }
    function _updateValues(address userAddr) private {
        uint userRate = _m_users[userAddr].user_rate;
        
        if(_m_is_user_joined[userAddr]) {
            _m_users[userAddr].user_rate = userRate + 1;

            _EMPTY_CELLS = _EMPTY_CELLS - 1;

        } else {
            _m_is_user_joined[userAddr] = true;
            _USER_COUNT = _USER_COUNT + 1;
            _m_users[userAddr].user_rate = userRate + 1;

            _EMPTY_CELLS = _EMPTY_CELLS - 1;
        }
    }
}
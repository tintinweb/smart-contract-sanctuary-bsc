/**
 *Submitted for verification at BscScan.com on 2022-11-07
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.16;
 
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable: new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
contract CellPaint is Context, Ownable {
    uint private _CELL_COUNT;
    uint private _EMPTY_CELLS;
    uint private _USER_COUNT;
    uint private _CONTRACT_PRICE;

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
    constructor() {
        _owner = _msgSender();
        _USER_COUNT = 0;
        _CELL_COUNT = 4000;
        _EMPTY_CELLS = 4000;
        _CONTRACT_PRICE = 1 ether; // 1 BNB  
    }
    event CellPainted(uint indexed indx);

    modifier OnlyInRange(uint indx) {
        require(indx < _CELL_COUNT, "Invalid index.");
        _;
    }
    modifier CheckWithdraw(address userAddr) {
        require(_m_user_withdraw[userAddr] == false && _m_users[userAddr].user_rate > 0, "User already withdrawed.");
        _;
    }

    receive() external payable {
    }
    fallback() external payable {
    }

// public
    function paintCell(uint cell_index, uint cell_color) OnlyInRange(cell_index) external {
        require(_a_cells[cell_index].color == Color.Empty, "Cell is already painted.");
        require(_uintToColorEnum(cell_color) != Color.Empty, "Color can not be empty.");

        _a_cells[cell_index] = Cell(cell_index, msg.sender ,_uintToColorEnum(cell_color));

        _updateValues(_msgSender());
    
        emit CellPainted(cell_index);
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
    function getUserRate(address userAddr) external view returns(uint) {
        uint rate = _m_users[userAddr].user_rate;
        return rate;
    }
    function withdraw() external {
        require(getEmptyCellCount() == 0, "There are still empty cell(s)");
        _withdraw(_msgSender());       
    }
// owner
    function _claimFunds(uint amount) external onlyOwner() {
        (bool success, ) = owner().call{value: amount}("");
        require(success, "Transaction failed.");
    }
// private
    function _withdraw(address userAddr) private CheckWithdraw(userAddr) {
        uint amount = (_CONTRACT_PRICE / _CELL_COUNT)*_m_users[userAddr].user_rate;
        _m_user_withdraw[userAddr] = true;
        _m_users[userAddr].user_rate = 0;

        require(address(this).balance > amount, "Contract has no enough balance for the transaction.");

        (bool success, ) = userAddr.call{value: amount}("");
        require(success, "Transaction failed.");
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
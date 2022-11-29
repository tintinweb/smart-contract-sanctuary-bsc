/**
 *Submitted for verification at BscScan.com on 2022-11-29
*/

// SPDX-License-Identifier: GPL-3.0

pragma solidity 0.8.16;

interface IERC20 {
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
    function renounceOwnership() public virtual onlyOwner {
        emit OwnershipTransferred(_owner, address(0));
        _owner = address(0);
    }
    function transferOwnership(address newOwner) public virtual onlyOwner {
        require(newOwner != address(0), "Ownable new owner is the zero address");
        emit OwnershipTransferred(_owner, newOwner);
        _owner = newOwner;
    }
}
// main
contract Lottery is Context, Ownable {
    IERC20 BlueArt = IERC20(0x81Aa4d3AD2A86E7A2cd44630C36ccAACD6b30568);
    address _poolAddress = 0x5c6FECE252F4107eeD802D55327Fea3F5F4f94d2;   
    
    uint private _BLA_DECIMALS = 1000000000; // 10^9 
    uint private _ticketPrice = 500;
    uint private _ticketCount = 0;

    address[3] private _winners;

    mapping(uint => address) private _ticketInfo;
    mapping(address => uint) private _playerTickets;

    event PlayerBokedTicket(address indexed player, uint indexed ticketID);
    event NewWinner(address indexed player, uint indexed prizeType);
    event TicketPriceChanged(uint newPrice);

    constructor() {
        _owner = _msgSender();
    }
    receive() external payable {}
    fallback() external payable {}

// public
    function buyTicket() external {
        bool success = BlueArt.transferFrom(_msgSender(), _poolAddress, _ticketPrice*_BLA_DECIMALS);
        require(success, "BLA transfer failed.");

        address playerAddr = _msgSender();

        _ticketInfo[_ticketCount] = playerAddr; 
        _playerTickets[playerAddr] += 1;

        emit PlayerBokedTicket(playerAddr, _ticketCount);
        _ticketCount += 1;
    }
    function getTicketInfo(uint ticket_indx) external view returns(address) {
        address ticketOwner = _ticketInfo[ticket_indx];
        return ticketOwner;
    }
    function getPlayerTickets(address player_addr) external view returns(uint) {
        uint playerTickets = _playerTickets[player_addr];
        return playerTickets;
    }
    function getTicketPrice() external view returns(uint) {
        return _ticketPrice;
    }
    function getTicketCount() external view returns(uint) {
        return _ticketCount;
    }
    function getPoolAddress() external view returns(address) {
        return _poolAddress;
    }
    function getWinners() external view returns(address[3] memory) {
        return _winners;
    }
// owner
    function setWinner(uint prize_type, uint ticket_indx) external onlyOwner {
        if(prize_type == 1) {
            _winners[0] = _ticketInfo[ticket_indx];
            emit NewWinner(_msgSender(), ticket_indx);
        }
        else if(prize_type == 2) {
            _winners[1] = _ticketInfo[ticket_indx];
            emit NewWinner(_msgSender(), ticket_indx);
        }
        else if(prize_type == 3) {
            _winners[2] = _ticketInfo[ticket_indx];
            emit NewWinner(_msgSender(), ticket_indx);
        } else {
            revert("Error: Invalid Prize Type. Prize types: 1, 2 or 3");
        }
    }
    function setPoolAddress(address new_pool_address) external onlyOwner {
        _poolAddress = new_pool_address;
    }
    function setTicketPrice(uint new_price) external onlyOwner {
        _ticketPrice = new_price;
        emit TicketPriceChanged(new_price);
    }
    function destroyContract() external onlyOwner {
        // only for protection purpose
        selfdestruct(payable(owner()));
    }
}
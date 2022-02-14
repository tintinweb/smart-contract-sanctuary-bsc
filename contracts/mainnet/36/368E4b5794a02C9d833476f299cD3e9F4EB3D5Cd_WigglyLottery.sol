// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./IERC20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./Pausable.sol";

contract WigglyLottery is Ownable, Pausable {
    using SafeMath for uint256;

    IERC20 token; // ERC20 Token Address

    uint256 private _ticketprice = 10000000000000000000; // 10 WGL;

    uint256 private _totalNumbers;

    address private burned_addr;

    mapping(address => uint256) private tickets;

    mapping(address => uint256) private ticketnumbers;

    mapping(uint256 => address) public luckyInvesters;

    address[] internal lotteryHolders;

    function Setup(address token_addr, address _burned_addr) public onlyOwner {
        token = IERC20(token_addr);
        burned_addr = address(_burned_addr);
    }

    function buyTicket(uint256 _amount)
        public
        payable
        whenNotPaused
        returns (bool)
    {
        require(
            safeTransferFrom(
                address(token),
                msg.sender,
                address(burned_addr),
                (_amount * _ticketprice)
            ),
            "TRANSFER FAILED"
        );

        tickets[msg.sender] += _amount;

        _addLotteryHolder(msg.sender);

        return true;
    }

    function getTicket(address _account) public view returns (uint256) {
        return tickets[_account];
    }

    function getTicketNumbers(address _account) public view returns (uint256) {
        return ticketnumbers[_account];
    }

    function _isLotteryHolder(address _account)
        public
        view
        returns (bool, uint256)
    {
        for (uint256 s = 0; s < lotteryHolders.length; s += 1) {
            if (_account == lotteryHolders[s]) return (true, s);
        }
        return (false, 0);
    }

    function totalUser() public view returns (uint256) {
        return lotteryHolders.length;
    }

    function delTicket(address _account) public onlyOwner returns (bool) {
        tickets[_account] = 0;
        return true;
    }

    // Owner Staff

    function lotterySetup() public onlyOwner returns (bool) {
        uint256 _numbers = 0;
        for (uint256 s = 0; s < lotteryHolders.length; s += 1) {
            _numbers += tickets[lotteryHolders[s]];
            ticketnumbers[lotteryHolders[s]] = _numbers; // set ticket numbers;
        }
        _totalNumbers = _numbers;
        return true;
    }

    function startLottery(uint256 _num) public onlyOwner returns (uint256) {
        uint256 _luckyNumber = random(_num) % _totalNumbers;

        for (uint256 s = 0; s < lotteryHolders.length; s += 1) {
            if (_luckyNumber <= ticketnumbers[lotteryHolders[s]]) {
                luckyInvesters[_num] = lotteryHolders[s];
                tickets[lotteryHolders[s]] = 0;
                ticketnumbers[lotteryHolders[s]] = 0;
                lotteryHolders[s] = lotteryHolders[lotteryHolders.length - 1];
                lotteryHolders.pop();
                break;
            }
        }

        return _luckyNumber;
    }

    function getLucky(uint256 _num) public view returns (address) {
        require(_num <= 5, "NOT IN THE DESIRED RANGE");
        return luckyInvesters[_num];
    }

    function resetLottery() public onlyOwner returns (bool) {
        for (uint256 s = 0; s < lotteryHolders.length; s += 1) {
            ticketnumbers[lotteryHolders[s]] = 0; // delete numbers;
            tickets[lotteryHolders[s]] = 0; // delete ticket
        }
        delete lotteryHolders;
        return true;
    }

    // Helpers

    function random(uint256 _num) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(
                        block.difficulty,
                        block.timestamp.add(_num),
                        lotteryHolders
                    )
                )
            );
    }

    function getUserById(uint256 _id) public view returns (address) {
        return lotteryHolders[_id];
    }

    function setTicketPrice(uint256 ticketprice)
        external
        onlyOwner
        returns (bool)
    {
        _ticketprice = ticketprice;
        return true;
    }

    function _addLotteryHolder(address _account) private {
        (bool blnIsLotteryHolder, ) = _isLotteryHolder(_account);
        if (!blnIsLotteryHolder) lotteryHolders.push(_account);
    }

    function safeTransferFrom(
        address _token,
        address from,
        address to,
        uint256 value
    ) internal returns (bool) {
        (bool success, bytes memory data) = _token.call(
            abi.encodeWithSelector(0x23b872dd, from, to, value)
        );
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function safeTransfer(
        address _token,
        address to,
        uint256 value
    ) internal returns (bool) {
        (bool success, bytes memory data) = _token.call(
            abi.encodeWithSelector(0xa9059cbb, to, value)
        );
        return (success && (data.length == 0 || abi.decode(data, (bool))));
    }

    function withdrawToken(uint256 _amount) external onlyOwner returns (bool) {
        require(token.transfer(owner(), _amount), "TRANSFER FAILED");
        return true;
    }

    function withdrawBnb() external onlyOwner returns (bool) {
        if (address(this).balance >= 0) {
            payable(owner()).transfer(address(this).balance);
        }
        return true;
    }
}
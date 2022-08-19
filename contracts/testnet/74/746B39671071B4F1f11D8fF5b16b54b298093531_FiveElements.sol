// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./modules/Permission.sol";

interface IHash {
    function getHash() external returns(bytes memory, uint16);
    function setSeed(string memory newSeed) external;
    function setWhitelist(address whiteAddress, bool tf) external;
}

contract FiveElements is Permission {
    using SafeERC20 for IERC20;
    IERC20 public usdtContract = IERC20(0x1A2a1eb97bEE6e7e786956794576fc82b866b0C2);

    uint public ticketPrice = 1000 ether;
    address public clubAddress = 0x89C61778241904C71DeF6A73C4E0115A7765398f;
    address public oneAddress = 0x89C61778241904C71DeF6A73C4E0115A7765398f;
    address public twoAddress = 0x89C61778241904C71DeF6A73C4E0115A7765398f;
    IHash private hashAddress = IHash(0xf976ae218392B0Aeab9B9315ce47A576A336A057);
     
    event Win(
        address buyer,
        bytes ticketHash,
        uint winBonus,
        uint time
    );

    struct Order {
        uint orderTime;
        bytes orderHash;
        uint winBouns;
    }

    mapping(uint8 => address[]) public fiveCamps;
    uint8 public isEnd = 1;
    uint8 public lastCamp;
    uint public endTime;
    uint public startTime;
    uint public addTime = 10;
    uint public pool;

    uint public campBouns;
    uint public onlyBouns;
    uint public seatBouns;

    mapping(address => mapping(uint8 => uint32)) public campQuantity;
    mapping(address => uint) public bouns;
    mapping(address => Order[]) public orderList;
    mapping(address => uint) public dividendBouns;
    mapping(address => uint) public allBouns;

    receive() external payable {}
    
    function getFrontAddress() public view returns(address){
        return fiveCamps[0][(fiveCamps[0].length - 1) / 2];
    }

    function getCampQuantity(address sender, uint8 camp) public view returns(uint32){
        return campQuantity[sender][camp];
    }

    function getCampAmount(uint8 camp) public view returns(uint){
        return fiveCamps[camp].length;
    }

    function isContract(address addr) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }

    function getAllComps(uint8 _comps) public view returns (address[] memory){
        address[] memory playerList = new address[](fiveCamps[_comps].length);
        for(uint i = 0; i < fiveCamps[_comps].length; i++){
            playerList[i] = fiveCamps[_comps][i];
        }
        return playerList;
    }

    function getAllOrderList(address _sender) public view returns (Order[] memory){
        Order[] memory newOrderList = new Order[](orderList[_sender].length);
        for(uint i = 0; i < orderList[_sender].length; i++){
            newOrderList[i] = orderList[_sender][i];
        }
        return newOrderList;
    }

    function buyTicket(uint8 camp, uint32 amount) public {
        require(amount < 1001, "Amount is too many");
        require(!isContract(msg.sender), "It is contracts");
        require(endTime > block.timestamp && startTime <= block.timestamp, "The game is end or not start");
        require(camp > 0 && camp < 6,"The camp is not exist");
        require(usdtContract.balanceOf(msg.sender) >= amount * ticketPrice,"Your coin is not enough");
        usdtContract.transferFrom(
            msg.sender,
            address(this),
            amount * ticketPrice
        );
        lastCamp = camp;
        _buyTicket(camp, amount);
    }

    function buyTicketRecommender(uint8 camp, uint32 amount, address recommender) public {
        require(amount < 1001, "Amount is too many");
        require(!isContract(msg.sender), "It is contracts");
        require(endTime > block.timestamp && startTime <= block.timestamp, "The game is end or not start");
        require(camp > 0 && camp < 6,"The camp is not exist");
        require(usdtContract.balanceOf(msg.sender) >= amount * ticketPrice,"Your coin is not enough");
        usdtContract.transferFrom(
            msg.sender,
            address(this),
            amount * ticketPrice
        );
        lastCamp = camp;
        _buyTicketRecommender(camp, amount, recommender);
    }

    function _buyTicket(uint8 camp, uint32 amount) private {
        if(endTime + addTime > block.timestamp + 180){
            endTime = block.timestamp + 180;
        }else{
            endTime = endTime + addTime;
        }
        for(uint32 i = 0; i < amount; i++){
            allocation();
            fiveCamps[camp].push(msg.sender);
            fiveCamps[0].push(msg.sender); 
            luckFive();
        }
        campQuantity[msg.sender][0] = campQuantity[msg.sender][0] + amount;
        campQuantity[msg.sender][camp] = campQuantity[msg.sender][camp] + amount;
    }

    function _buyTicketRecommender(uint8 camp, uint32 amount, address recommender) private {
        if(endTime + addTime > block.timestamp + 180){
            endTime = block.timestamp + 180;
        }else{
            endTime = endTime + addTime;
        }
        for(uint32 i = 0; i < amount; i++){
            allocationRecommender(recommender);
            fiveCamps[camp].push(msg.sender);
            fiveCamps[0].push(msg.sender);
            luckFive();
        }
        campQuantity[msg.sender][0] = campQuantity[msg.sender][0] + amount;
        campQuantity[msg.sender][camp] = campQuantity[msg.sender][camp] + amount;
    }

    function allocation() private{
        if(fiveCamps[0].length == 0){
            pool = pool + (ticketPrice * 905 / 1000 );
            // transferUsdt([clubAddress, oneAddress, twoAddress], [(ticketPrice * 25 / 1000 ), (ticketPrice * 54 / 1000 ), (ticketPrice * 10 / 1000 )]);
            bouns[clubAddress] = bouns[clubAddress] + (ticketPrice * 25 / 1000 );
            bouns[oneAddress] = bouns[oneAddress] + (ticketPrice * 56 / 1000 );
            bouns[twoAddress] = bouns[twoAddress] + (ticketPrice * 14 / 1000 );
        }else{
            pool = pool + (ticketPrice * 380 / 1000 );
            recordBouns(getFrontAddress(), (ticketPrice * 525 / 1000 ));
            // dividendBouns[getFrontAddress()] = dividendBouns[getFrontAddress()] + (ticketPrice * 525 / 1000 );
            // allBouns[getFrontAddress()] = allBouns[getFrontAddress()] + (ticketPrice * 525 / 1000 );
            // transferUsdt([clubAddress, oneAddress, twoAddress], [(ticketPrice * 25 / 1000 ), (ticketPrice * 54 / 1000 ), (ticketPrice * 10 / 1000 )]);
            bouns[clubAddress] = bouns[clubAddress] + (ticketPrice * 25 / 1000 );
            bouns[oneAddress] = bouns[oneAddress] + (ticketPrice * 56 / 1000 );
            bouns[twoAddress] = bouns[twoAddress] + (ticketPrice * 14 / 1000 );
        }
    }

    function allocationRecommender(address recommender) private{
        if(fiveCamps[0].length == 0){
            pool = pool + (ticketPrice * 905 / 1000 );
            recordBouns(recommender, (ticketPrice * 20 / 1000 ));
            // dividendBouns[recommender] =  dividendBouns[recommender] + (ticketPrice * 20 / 1000 );
            // allBouns[recommender] = allBouns[recommender] + (ticketPrice * 20 / 1000 );
            // transferUsdt([clubAddress, oneAddress, twoAddress], [(ticketPrice * 25 / 1000 ), (ticketPrice * 40 / 1000 ), (ticketPrice * 10 / 1000 )]);
            bouns[clubAddress] = bouns[clubAddress] + (ticketPrice * 25 / 1000 );
            bouns[oneAddress] = bouns[oneAddress] + (ticketPrice * 40 / 1000 );
            bouns[twoAddress] = bouns[twoAddress] + (ticketPrice * 10 / 1000 );
        }else{
            pool = pool + (ticketPrice * 380 / 1000 );
            recordBouns(getFrontAddress(), (ticketPrice * 525 / 1000 ));
            recordBouns(recommender, (ticketPrice * 20 / 1000 ));
            // dividendBouns[getFrontAddress()] = dividendBouns[getFrontAddress()] + (ticketPrice * 525 / 1000 );
            // dividendBouns[recommender] = dividendBouns[recommender] + (ticketPrice * 20 / 1000 );
            // allBouns[getFrontAddress()] = allBouns[getFrontAddress()] + (ticketPrice * 525 / 1000 );
            // allBouns[recommender] = allBouns[recommender] + (ticketPrice * 20 / 1000 );
            
            // transferUsdt([clubAddress, oneAddress, twoAddress], [(ticketPrice * 25 / 1000 ), (ticketPrice * 40 / 1000 ), (ticketPrice * 10 / 1000 )]);
            bouns[clubAddress] = bouns[clubAddress] + (ticketPrice * 25 / 1000 );
            bouns[oneAddress] = bouns[oneAddress] + (ticketPrice * 40 / 1000 );
            bouns[twoAddress] = bouns[twoAddress] + (ticketPrice * 10 / 1000 );
        }
    }

    function transferUsdt(address[3] memory toAddress, uint[3] memory _usdrAmount) private {
        require(toAddress.length == _usdrAmount.length, "address.lengtj must equal _usdtAmount.length");
        for(uint8 i = 0; i < toAddress.length; i++){
            usdtContract.safeTransfer(toAddress[i], _usdrAmount[i]);
        }
    }

    function luckFive() private {
        (bytes memory newHash, uint16 count)  = hashAddress.getHash();      
        if(count < 8){
            pushOrderList(newHash, 0);
        }else if(count == 8){
            uint winBouns = pool * 1 / 1000;
            pushOrderList(newHash, winBouns);
        }else if(count == 9){
            uint winBouns = pool * 3 / 1000;
            pushOrderList(newHash, winBouns);
        }else if(count == 10){
            uint winBouns = pool * 5 / 1000;
            pushOrderList(newHash, winBouns);
        }else if(count == 11){
            uint winBouns = pool * 10 / 1000;
            pushOrderList(newHash, winBouns);
        }else if(count == 12){
            uint winBouns = pool * 50 / 1000;
            endTime = endTime - 30;
            pushOrderList(newHash, winBouns);
        }else if(count == 13){
            uint winBouns = pool * 100 / 1000;
            endTime = endTime - 60;
            pushOrderList(newHash, winBouns);
        }else if(count == 14){
            uint winBouns = pool * 150 / 1000;
            endTime = endTime - 90;
            pushOrderList(newHash, winBouns);
        }else if(count == 15){
            uint winBouns = pool * 250 / 1000;
            endTime = endTime - 120;
            pushOrderList(newHash, winBouns);
        }else if(count >= 16){
            uint winBouns = pool * 500 / 1000;
            endTime = endTime - 150;
            pushOrderList(newHash, winBouns);
        }
    }

    function pushOrderList(bytes memory newHash, uint winBouns) private {
        pool = pool - winBouns;
        bouns[msg.sender] = bouns[msg.sender] + winBouns;
        allBouns[msg.sender] = allBouns[msg.sender] + winBouns;
        orderList[msg.sender].push(Order({orderTime : block.timestamp, orderHash: newHash, winBouns: winBouns}));
        emit Win(msg.sender, newHash, winBouns, block.timestamp);
    }

    function withdraw() public {
        uint transCoin = bouns[msg.sender] + dividendBouns[msg.sender];
        require(transCoin > 0, "Your bouns is 0");
        bouns[msg.sender] = 0;
        dividendBouns[msg.sender] = 0;
        usdtContract.approve(msg.sender, transCoin);
        usdtContract.safeTransfer(
            address(this),
            transCoin
        );
    }

    function getAllCompsLength(uint8 _campsLength) public view returns(uint){
        return getAllComps(_campsLength).length;
    }

    function endGame() public {
        require(endTime < block.timestamp, "The game is not end");
        require(isEnd == uint8(1),"Already endGame");
        isEnd = uint8(2);
        uint allTicket = getAllComps(uint8(0)).length;
        if(allTicket == 0){
            bouns[oneAddress] = bouns[oneAddress] + pool;
            pool = 0;
        }else{
            onlyBouns = pool * 500 / 1000;
            recordBouns(getAllComps(uint8(0))[allTicket - 1], onlyBouns);
            // dividendBouns[getAllComps(uint8(0))[allTicket - 1]] = dividendBouns[getAllComps(uint8(0))[allTicket - 1]] + onlyBouns;
            // allBouns[getAllComps(uint8(0))[allTicket - 1]] = allBouns[getAllComps(uint8(0))[allTicket - 1]] + onlyBouns;
            
            if(allTicket < 2){
                seatBouns = pool * 100 / 1000 / (getAllComps(uint8(0)).length - 1);
                recordBouns(clubAddress, seatBouns);
                // bouns[clubAddress] = bouns[clubAddress] + seatBouns;
            }else if(allTicket > 2 && allTicket < 20){
                seatBouns = pool * 100 / 1000 / (getAllComps(uint8(0)).length - 1);
                for(uint i = 0; i < (getAllComps(uint8(0)).length - 1); i--){
                    recordBouns(getAllComps(uint8(0))[allTicket - i], seatBouns);
                    // dividendBouns[getAllComps(uint8(0))[allTicket - i]] = dividendBouns[getAllComps(uint8(0))[allTicket - i]] + seatBouns;
                    // allBouns[getAllComps(uint8(0))[allTicket - i]] = allBouns[getAllComps(uint8(0))[allTicket - i]] + seatBouns;
                }
            }else{
                seatBouns = pool * 5 / 1000;
                for(uint i = 2; i < 22; i++){
                    recordBouns(getAllComps(uint8(0))[allTicket - i], seatBouns);
                    // dividendBouns[getAllComps(uint8(0))[allTicket - i]] = dividendBouns[getAllComps(uint8(0))[allTicket - i]] + seatBouns;
                    // allBouns[getAllComps(uint8(0))[allTicket - i]] = allBouns[getAllComps(uint8(0))[allTicket - i]] + seatBouns;
                }
            }
            
            campBouns = pool * 400 / 1000 / getAllComps(lastCamp).length;
            for(uint j = 0; j < getAllComps(lastCamp).length; j++){
                recordBouns(getAllComps(lastCamp)[j], campBouns);
                // dividendBouns[getAllComps(lastCamp)[j]] = dividendBouns[getAllComps(lastCamp)[j]] + campBouns;
                // allBouns[getAllComps(lastCamp)[j]] = allBouns[getAllComps(lastCamp)[j]] + campBouns;
            }
            pool = 0;
        }
    }

    function recordBouns(address recordAddress, uint recordUsdr) private {
        dividendBouns[recordAddress] = dividendBouns[recordAddress] + recordUsdr;
        allBouns[recordAddress] = allBouns[recordAddress] + recordUsdr;
    }

    function getEndTime()public view returns(uint){
        return endTime;
    }

    function setUsdtContract(
        address _usdtContract
    ) external onlyRole(MANAGER_ROLE){
        _setUsdtContract(_usdtContract);
    }

    function _setUsdtContract(address _usdtContract) internal {
        usdtContract = IERC20(_usdtContract);
    }

    function setTime(uint _startTime,uint _endTime, uint _pool) external onlyRole(MANAGER_ROLE){
        // require(endTime < block.timestamp, "The game is not end");
        require(_endTime > _startTime,"endTime must more than startTime !");
        isEnd = uint8(1);
        startTime = _startTime;
        endTime = _endTime;
        usdtContract.transferFrom(
            msg.sender,
            address(this),
            _pool * 1e18
        );
        pool = pool + (_pool * 1e18);
    }

    function setWhitelist(address whiteAddress, bool tf) external onlyRole(MANAGER_ROLE){
        hashAddress.setWhitelist( whiteAddress, tf);
    }

    function setSeed(string memory newSeed) external onlyRole(MANAGER_ROLE){
        hashAddress.setSeed(newSeed);
    }

}

    // uint256 internal randomSeed = 1;
    // bytes32 public _bhash;
    // function _getRandomNumber() public returns (bytes32){
    //     // _updateRamdomSeed();
    //     _bhash =  keccak256(abi.encodePacked(
    //         randomSeed, block.timestamp, blockhash(block.number - 1), tx.origin
    //     ));
    //     return keccak256(abi.encodePacked(
    //         randomSeed, block.timestamp, blockhash(block.number - 1), tx.origin
    //     ));
    // }

    // function toHex16(bytes16 data) internal pure returns(bytes32 result) {
    //     result = bytes32(data) & 0xFFFFFFFFFFFFFFFF000000000000000000000000000000000000000000000000 |
    //         (bytes32(data) & 0x0000000000000000FFFFFFFFFFFFFFFF00000000000000000000000000000000) >> 64;
    //     result = result & 0xFFFFFFFF000000000000000000000000FFFFFFFF000000000000000000000000 |
    //         (result & 0x00000000FFFFFFFF000000000000000000000000FFFFFFFF0000000000000000) >> 32;
    //     result = result & 0xFFFF000000000000FFFF000000000000FFFF000000000000FFFF000000000000 |
    //         (result & 0x0000FFFF000000000000FFFF000000000000FFFF000000000000FFFF00000000) >> 16;
    //     result = result & 0xFF000000FF000000FF000000FF000000FF000000FF000000FF000000FF000000 |
    //         (result & 0x00FF000000FF000000FF000000FF000000FF000000FF000000FF000000FF0000) >> 8;
    //     result = (result & 0xF000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000) >> 4 |
    //         (result & 0x0F000F000F000F000F000F000F000F000F000F000F000F000F000F000F000F00) >> 8;
    //     result = bytes32(0x3030303030303030303030303030303030303030303030303030303030303030 +
    //         uint256(result) +
    //         (uint256(result) + 0x0606060606060606060606060606060606060606060606060606060606060606 >> 4 &
    //         0x0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F0F) * 7);
    // }

    // function toHex(bytes32 data) public pure returns(string memory) {
    //     return string(abi.encodePacked("0x", toHex16(bytes16(data)), toHex16(bytes16(data << 128))));
    // }

    // function lucky5(bytes32 input) public pure returns( uint8) {
    //     bytes memory hashHex = bytes(toHex(input));
    //     uint256 x = hashHex.length;

    //     //string[] memory str = new string[](x);

    //     uint8 count = 0;
    //     // string memory ans = "";

    //     for (uint256 i = 1; i <= x - 1; i++) {
    //         string memory a = getSlice(i, i, toHex(input));
    //         //str[i]= a;
    //         // ans = a;
    //         if (compareStrings(a, "5")) {
    //             count++;
    //         }
    //     }

    //     return count;

    // }

    // function compareStrings(string memory a, string memory b) public pure returns(bool) {
    //     return (keccak256(abi.encodePacked((a))) == keccak256(abi.encodePacked((b))));
    // }

    // function getSlice(uint256 begin, uint256 end, string memory text) public pure returns(string memory) {
    //     bytes memory a = new bytes(end - begin + 1);
    //     for (uint i = 0; i <= end - begin; i++) {
    //         a[i] = bytes(text)[i + begin - 1];
    //     }
    //     return string(a);
    // }

    // function testGet5() public returns (uint8){
    //     count5 = lucky5(_getRandomNumber());
    //     return count5;
    // }
    // uint8 public count5;

    // function _updateRamdomSeed() private {
    //     if(randomSeed % 3 == 0){
    //         randomSeed++;
    //     }else if(randomSeed % 3 == 1){
    //         randomSeed = randomSeed + 5;
    //     }else if(randomSeed % 3 == 2){
    //         randomSeed = randomSeed + 6;
    //     }
    // }

    

// address[] public fiveCamps[0];
// address[] public metal;
// address[] public wood;
// address[] public water;
// address[] public fire;
// address[] public earth;

// if(camp == 1){
//     for(uint32 i = 0; i < amount; i++){
//         metal.push(msg.sender);
//         fiveCamps[0].push(msg.sender);
        
//     }
//     campQuantity[msg.sender][camp] = campQuantity[msg.sender][camp] + amount;
//     campAmount[camp] = campAmount[camp] + amount;
// }else if(camp == 2){
//     for(uint32 i = 0; i < amount; i++){
//         wood.push(msg.sender);
//         fiveCamps[0].push(msg.sender);
//         allocationRecommender(recommender);
//     }
//     campQuantity[msg.sender][camp] = campQuantity[msg.sender][camp] + amount;
//     campAmount[camp] = campAmount[camp] + amount;
// }else if(camp == 3){
//     for(uint32 i = 0; i < amount; i++){
//         water.push(msg.sender);
//         fiveCamps[0].push(msg.sender);
//         allocationRecommender(recommender);
//     }
//     campQuantity[msg.sender][camp] = campQuantity[msg.sender][camp] + amount;
//     campAmount[camp] = campAmount[camp] + amount;
// }else if(camp == 4){
//     for(uint32 i = 0; i < amount; i++){
//         fire.push(msg.sender);
//         fiveCamps[0].push(msg.sender);
//         allocationRecommender(recommender);
//     }
//     campQuantity[msg.sender][camp] = campQuantity[msg.sender][camp] + amount;
//     campAmount[camp] = campAmount[camp] + amount;
// }else if(camp == 5){
//     for(uint32 i = 0; i < amount; i++){
//         earth.push(msg.sender);
//         fiveCamps[0].push(msg.sender);
//         allocationRecommender(recommender);
//     }
//     campQuantity[msg.sender][camp] = campQuantity[msg.sender][camp] + amount;
//     campAmount[camp] = campAmount[camp] + amount;
// }

// if(lastCamp == 1){
            
// }else if(lastCamp == 2){
//     campBouns = pool * 400 / 1000 / wood.length;
//     for(uint j = 0; j < wood.length - 1; j++){
//         dividendBouns[wood[j]] = dividendBouns[wood[j]] + campBouns;
//     }
// }else if(lastCamp == 3){
//     campBouns = pool * 400 / 1000 / water.length;
//     for(uint j = 0; j < water.length - 1; j++){
//         dividendBouns[water[j]] = dividendBouns[water[j]] + campBouns;
//     }
// }else if(lastCamp == 4){
//     campBouns = pool * 400 / 1000 / fire.length;
//     for(uint j = 0; j < fire.length - 1; j++){
//         dividendBouns[fire[j]] = dividendBouns[fire[j]] + campBouns;
//     }
// }else if(lastCamp == 5){
//     campBouns = pool * 400 / 1000 / earth.length;
//     for(uint j = 0; j < earth.length - 1; j++){
//         dividendBouns[earth[j]] = dividendBouns[earth[j]] + campBouns;
//     }
// }

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC20 standard as defined in the EIP.
 */
interface IERC20 {
    /**
     * @dev Returns the amount of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the amount of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves `amount` tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 amount) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets `amount` as the allowance of `spender` over the caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 amount) external returns (bool);

    /**
     * @dev Moves `amount` tokens from `from` to `to` using the
     * allowance mechanism. `amount` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(
        address from,
        address to,
        uint256 amount
    ) external returns (bool);

    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (token/ERC20/utils/SafeERC20.sol)

pragma solidity ^0.8.0;

import "../IERC20.sol";
import "../../../utils/Address.sol";

/**
 * @title SafeERC20
 * @dev Wrappers around ERC20 operations that throw on failure (when the token
 * contract returns false). Tokens that return no value (and instead revert or
 * throw on failure) are also supported, non-reverting calls are assumed to be
 * successful.
 * To use this library you can add a `using SafeERC20 for IERC20;` statement to your contract,
 * which allows you to call the safe operations as `token.safeTransfer(...)`, etc.
 */
library SafeERC20 {
    using Address for address;

    function safeTransfer(
        IERC20 token,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transfer.selector, to, value));
    }

    function safeTransferFrom(
        IERC20 token,
        address from,
        address to,
        uint256 value
    ) internal {
        _callOptionalReturn(token, abi.encodeWithSelector(token.transferFrom.selector, from, to, value));
    }

    /**
     * @dev Deprecated. This function has issues similar to the ones found in
     * {IERC20-approve}, and its usage is discouraged.
     *
     * Whenever possible, use {safeIncreaseAllowance} and
     * {safeDecreaseAllowance} instead.
     */
    function safeApprove(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        // safeApprove should only be called when setting an initial allowance,
        // or when resetting it to zero. To increase and decrease it, use
        // 'safeIncreaseAllowance' and 'safeDecreaseAllowance'
        require(
            (value == 0) || (token.allowance(address(this), spender) == 0),
            "SafeERC20: approve from non-zero to non-zero allowance"
        );
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, value));
    }

    function safeIncreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        uint256 newAllowance = token.allowance(address(this), spender) + value;
        _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
    }

    function safeDecreaseAllowance(
        IERC20 token,
        address spender,
        uint256 value
    ) internal {
        unchecked {
            uint256 oldAllowance = token.allowance(address(this), spender);
            require(oldAllowance >= value, "SafeERC20: decreased allowance below zero");
            uint256 newAllowance = oldAllowance - value;
            _callOptionalReturn(token, abi.encodeWithSelector(token.approve.selector, spender, newAllowance));
        }
    }

    /**
     * @dev Imitates a Solidity high-level call (i.e. a regular function call to a contract), relaxing the requirement
     * on the return value: the return value is optional (but if data is returned, it must not be false).
     * @param token The token targeted by the call.
     * @param data The call data (encoded using abi.encode or one of its variants).
     */
    function _callOptionalReturn(IERC20 token, bytes memory data) private {
        // We need to perform a low level call here, to bypass Solidity's return data size checking mechanism, since
        // we're implementing it ourselves. We use {Address.functionCall} to perform this call, which verifies that
        // the target address contains contract code and also asserts for success in the low-level call.

        bytes memory returndata = address(token).functionCall(data, "SafeERC20: low-level call failed");
        if (returndata.length > 0) {
            // Return data is optional
            require(abi.decode(returndata, (bool)), "SafeERC20: ERC20 operation did not succeed");
        }
    }
}

// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;
import "@openzeppelin/contracts/access/AccessControl.sol";

abstract contract Permission is AccessControl{
    bytes32 public constant MANAGER_ROLE = keccak256("MANAGER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    
    constructor(){
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(MANAGER_ROLE, _msgSender());
        _setupRole(MINTER_ROLE, _msgSender());
    }

    function grantMinter(address account) external onlyRole(MANAGER_ROLE){
        _grantRole(MINTER_ROLE, account);
    }

    function revokeMinter(address account) external onlyRole(MANAGER_ROLE){
        _revokeRole(MINTER_ROLE, account);
    }

    function grantManager(address account) external onlyRole(DEFAULT_ADMIN_ROLE){
        _grantRole(MANAGER_ROLE, account);
    }

    function revokeManager(address account) external onlyRole(DEFAULT_ADMIN_ROLE){
        _revokeRole(MANAGER_ROLE, account);
    }

    function transferAdmin(address account) external onlyRole(DEFAULT_ADMIN_ROLE){
        _revokeRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(DEFAULT_ADMIN_ROLE, account);
    }

}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (utils/Address.sol)

pragma solidity ^0.8.1;

/**
 * @dev Collection of functions related to the address type
 */
library Address {
    /**
     * @dev Returns true if `account` is a contract.
     *
     * [IMPORTANT]
     * ====
     * It is unsafe to assume that an address for which this function returns
     * false is an externally-owned account (EOA) and not a contract.
     *
     * Among others, `isContract` will return false for the following
     * types of addresses:
     *
     *  - an externally-owned account
     *  - a contract in construction
     *  - an address where a contract will be created
     *  - an address where a contract lived, but was destroyed
     * ====
     *
     * [IMPORTANT]
     * ====
     * You shouldn't rely on `isContract` to protect against flash loan attacks!
     *
     * Preventing calls from contracts is highly discouraged. It breaks composability, breaks support for smart wallets
     * like Gnosis Safe, and does not provide security since it can be circumvented by calling from a contract
     * constructor.
     * ====
     */
    function isContract(address account) internal view returns (bool) {
        // This method relies on extcodesize/address.code.length, which returns 0
        // for contracts in construction, since the code is only stored at the end
        // of the constructor execution.

        return account.code.length > 0;
    }

    /**
     * @dev Replacement for Solidity's `transfer`: sends `amount` wei to
     * `recipient`, forwarding all available gas and reverting on errors.
     *
     * https://eips.ethereum.org/EIPS/eip-1884[EIP1884] increases the gas cost
     * of certain opcodes, possibly making contracts go over the 2300 gas limit
     * imposed by `transfer`, making them unable to receive funds via
     * `transfer`. {sendValue} removes this limitation.
     *
     * https://diligence.consensys.net/posts/2019/09/stop-using-soliditys-transfer-now/[Learn more].
     *
     * IMPORTANT: because control is transferred to `recipient`, care must be
     * taken to not create reentrancy vulnerabilities. Consider using
     * {ReentrancyGuard} or the
     * https://solidity.readthedocs.io/en/v0.5.11/security-considerations.html#use-the-checks-effects-interactions-pattern[checks-effects-interactions pattern].
     */
    function sendValue(address payable recipient, uint256 amount) internal {
        require(address(this).balance >= amount, "Address: insufficient balance");

        (bool success, ) = recipient.call{value: amount}("");
        require(success, "Address: unable to send value, recipient may have reverted");
    }

    /**
     * @dev Performs a Solidity function call using a low level `call`. A
     * plain `call` is an unsafe replacement for a function call: use this
     * function instead.
     *
     * If `target` reverts with a revert reason, it is bubbled up by this
     * function (like regular Solidity function calls).
     *
     * Returns the raw returned data. To convert to the expected return value,
     * use https://solidity.readthedocs.io/en/latest/units-and-global-variables.html?highlight=abi.decode#abi-encoding-and-decoding-functions[`abi.decode`].
     *
     * Requirements:
     *
     * - `target` must be a contract.
     * - calling `target` with `data` must not revert.
     *
     * _Available since v3.1._
     */
    function functionCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionCall(target, data, "Address: low-level call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`], but with
     * `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, 0, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but also transferring `value` wei to `target`.
     *
     * Requirements:
     *
     * - the calling contract must have an ETH balance of at least `value`.
     * - the called Solidity function must be `payable`.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value
    ) internal returns (bytes memory) {
        return functionCallWithValue(target, data, value, "Address: low-level call with value failed");
    }

    /**
     * @dev Same as {xref-Address-functionCallWithValue-address-bytes-uint256-}[`functionCallWithValue`], but
     * with `errorMessage` as a fallback revert reason when `target` reverts.
     *
     * _Available since v3.1._
     */
    function functionCallWithValue(
        address target,
        bytes memory data,
        uint256 value,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(address(this).balance >= value, "Address: insufficient balance for call");
        require(isContract(target), "Address: call to non-contract");

        (bool success, bytes memory returndata) = target.call{value: value}(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(address target, bytes memory data) internal view returns (bytes memory) {
        return functionStaticCall(target, data, "Address: low-level static call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a static call.
     *
     * _Available since v3.3._
     */
    function functionStaticCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal view returns (bytes memory) {
        require(isContract(target), "Address: static call to non-contract");

        (bool success, bytes memory returndata) = target.staticcall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(address target, bytes memory data) internal returns (bytes memory) {
        return functionDelegateCall(target, data, "Address: low-level delegate call failed");
    }

    /**
     * @dev Same as {xref-Address-functionCall-address-bytes-string-}[`functionCall`],
     * but performing a delegate call.
     *
     * _Available since v3.4._
     */
    function functionDelegateCall(
        address target,
        bytes memory data,
        string memory errorMessage
    ) internal returns (bytes memory) {
        require(isContract(target), "Address: delegate call to non-contract");

        (bool success, bytes memory returndata) = target.delegatecall(data);
        return verifyCallResult(success, returndata, errorMessage);
    }

    /**
     * @dev Tool to verifies that a low level call was successful, and revert if it wasn't, either by bubbling the
     * revert reason using the provided one.
     *
     * _Available since v4.3._
     */
    function verifyCallResult(
        bool success,
        bytes memory returndata,
        string memory errorMessage
    ) internal pure returns (bytes memory) {
        if (success) {
            return returndata;
        } else {
            // Look for revert reason and bubble it up if present
            if (returndata.length > 0) {
                // The easiest way to bubble the revert reason is using memory via assembly

                assembly {
                    let returndata_size := mload(returndata)
                    revert(add(32, returndata), returndata_size)
                }
            } else {
                revert(errorMessage);
            }
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.5.0) (access/AccessControl.sol)

pragma solidity ^0.8.0;

import "./IAccessControl.sol";
import "../utils/Context.sol";
import "../utils/Strings.sol";
import "../utils/introspection/ERC165.sol";

/**
 * @dev Contract module that allows children to implement role-based access
 * control mechanisms. This is a lightweight version that doesn't allow enumerating role
 * members except through off-chain means by accessing the contract event logs. Some
 * applications may benefit from on-chain enumerability, for those cases see
 * {AccessControlEnumerable}.
 *
 * Roles are referred to by their `bytes32` identifier. These should be exposed
 * in the external API and be unique. The best way to achieve this is by
 * using `public constant` hash digests:
 *
 * ```
 * bytes32 public constant MY_ROLE = keccak256("MY_ROLE");
 * ```
 *
 * Roles can be used to represent a set of permissions. To restrict access to a
 * function call, use {hasRole}:
 *
 * ```
 * function foo() public {
 *     require(hasRole(MY_ROLE, msg.sender));
 *     ...
 * }
 * ```
 *
 * Roles can be granted and revoked dynamically via the {grantRole} and
 * {revokeRole} functions. Each role has an associated admin role, and only
 * accounts that have a role's admin role can call {grantRole} and {revokeRole}.
 *
 * By default, the admin role for all roles is `DEFAULT_ADMIN_ROLE`, which means
 * that only accounts with this role will be able to grant or revoke other
 * roles. More complex role relationships can be created by using
 * {_setRoleAdmin}.
 *
 * WARNING: The `DEFAULT_ADMIN_ROLE` is also its own admin: it has permission to
 * grant and revoke this role. Extra precautions should be taken to secure
 * accounts that have been granted it.
 */
abstract contract AccessControl is Context, IAccessControl, ERC165 {
    struct RoleData {
        mapping(address => bool) members;
        bytes32 adminRole;
    }

    mapping(bytes32 => RoleData) private _roles;

    bytes32 public constant DEFAULT_ADMIN_ROLE = 0x00;

    /**
     * @dev Modifier that checks that an account has a specific role. Reverts
     * with a standardized message including the required role.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     *
     * _Available since v4.1._
     */
    modifier onlyRole(bytes32 role) {
        _checkRole(role, _msgSender());
        _;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IAccessControl).interfaceId || super.supportsInterface(interfaceId);
    }

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) public view virtual override returns (bool) {
        return _roles[role].members[account];
    }

    /**
     * @dev Revert with a standard message if `account` is missing `role`.
     *
     * The format of the revert reason is given by the following regular expression:
     *
     *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
     */
    function _checkRole(bytes32 role, address account) internal view virtual {
        if (!hasRole(role, account)) {
            revert(
                string(
                    abi.encodePacked(
                        "AccessControl: account ",
                        Strings.toHexString(uint160(account), 20),
                        " is missing role ",
                        Strings.toHexString(uint256(role), 32)
                    )
                )
            );
        }
    }

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) public view virtual override returns (bytes32) {
        return _roles[role].adminRole;
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _grantRole(role, account);
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) public virtual override onlyRole(getRoleAdmin(role)) {
        _revokeRole(role, account);
    }

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been revoked `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) public virtual override {
        require(account == _msgSender(), "AccessControl: can only renounce roles for self");

        _revokeRole(role, account);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event. Note that unlike {grantRole}, this function doesn't perform any
     * checks on the calling account.
     *
     * [WARNING]
     * ====
     * This function should only be called from the constructor when setting
     * up the initial roles for the system.
     *
     * Using this function in any other way is effectively circumventing the admin
     * system imposed by {AccessControl}.
     * ====
     *
     * NOTE: This function is deprecated in favor of {_grantRole}.
     */
    function _setupRole(bytes32 role, address account) internal virtual {
        _grantRole(role, account);
    }

    /**
     * @dev Sets `adminRole` as ``role``'s admin role.
     *
     * Emits a {RoleAdminChanged} event.
     */
    function _setRoleAdmin(bytes32 role, bytes32 adminRole) internal virtual {
        bytes32 previousAdminRole = getRoleAdmin(role);
        _roles[role].adminRole = adminRole;
        emit RoleAdminChanged(role, previousAdminRole, adminRole);
    }

    /**
     * @dev Grants `role` to `account`.
     *
     * Internal function without access restriction.
     */
    function _grantRole(bytes32 role, address account) internal virtual {
        if (!hasRole(role, account)) {
            _roles[role].members[account] = true;
            emit RoleGranted(role, account, _msgSender());
        }
    }

    /**
     * @dev Revokes `role` from `account`.
     *
     * Internal function without access restriction.
     */
    function _revokeRole(bytes32 role, address account) internal virtual {
        if (hasRole(role, account)) {
            _roles[role].members[account] = false;
            emit RoleRevoked(role, account, _msgSender());
        }
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (access/IAccessControl.sol)

pragma solidity ^0.8.0;

/**
 * @dev External interface of AccessControl declared to support ERC165 detection.
 */
interface IAccessControl {
    /**
     * @dev Emitted when `newAdminRole` is set as ``role``'s admin role, replacing `previousAdminRole`
     *
     * `DEFAULT_ADMIN_ROLE` is the starting admin for all roles, despite
     * {RoleAdminChanged} not being emitted signaling this.
     *
     * _Available since v3.1._
     */
    event RoleAdminChanged(bytes32 indexed role, bytes32 indexed previousAdminRole, bytes32 indexed newAdminRole);

    /**
     * @dev Emitted when `account` is granted `role`.
     *
     * `sender` is the account that originated the contract call, an admin role
     * bearer except when using {AccessControl-_setupRole}.
     */
    event RoleGranted(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Emitted when `account` is revoked `role`.
     *
     * `sender` is the account that originated the contract call:
     *   - if using `revokeRole`, it is the admin role bearer
     *   - if using `renounceRole`, it is the role bearer (i.e. `account`)
     */
    event RoleRevoked(bytes32 indexed role, address indexed account, address indexed sender);

    /**
     * @dev Returns `true` if `account` has been granted `role`.
     */
    function hasRole(bytes32 role, address account) external view returns (bool);

    /**
     * @dev Returns the admin role that controls `role`. See {grantRole} and
     * {revokeRole}.
     *
     * To change a role's admin, use {AccessControl-_setRoleAdmin}.
     */
    function getRoleAdmin(bytes32 role) external view returns (bytes32);

    /**
     * @dev Grants `role` to `account`.
     *
     * If `account` had not been already granted `role`, emits a {RoleGranted}
     * event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function grantRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from `account`.
     *
     * If `account` had been granted `role`, emits a {RoleRevoked} event.
     *
     * Requirements:
     *
     * - the caller must have ``role``'s admin role.
     */
    function revokeRole(bytes32 role, address account) external;

    /**
     * @dev Revokes `role` from the calling account.
     *
     * Roles are often managed via {grantRole} and {revokeRole}: this function's
     * purpose is to provide a mechanism for accounts to lose their privileges
     * if they are compromised (such as when a trusted device is misplaced).
     *
     * If the calling account had been granted `role`, emits a {RoleRevoked}
     * event.
     *
     * Requirements:
     *
     * - the caller must be `account`.
     */
    function renounceRole(bytes32 role, address account) external;
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Context.sol)

pragma solidity ^0.8.0;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/Strings.sol)

pragma solidity ^0.8.0;

/**
 * @dev String operations.
 */
library Strings {
    bytes16 private constant _HEX_SYMBOLS = "0123456789abcdef";

    /**
     * @dev Converts a `uint256` to its ASCII `string` decimal representation.
     */
    function toString(uint256 value) internal pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT licence
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol

        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation.
     */
    function toHexString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0x00";
        }
        uint256 temp = value;
        uint256 length = 0;
        while (temp != 0) {
            length++;
            temp >>= 8;
        }
        return toHexString(value, length);
    }

    /**
     * @dev Converts a `uint256` to its ASCII `string` hexadecimal representation with fixed length.
     */
    function toHexString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(2 * length + 2);
        buffer[0] = "0";
        buffer[1] = "x";
        for (uint256 i = 2 * length + 1; i > 1; --i) {
            buffer[i] = _HEX_SYMBOLS[value & 0xf];
            value >>= 4;
        }
        require(value == 0, "Strings: hex length insufficient");
        return string(buffer);
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/ERC165.sol)

pragma solidity ^0.8.0;

import "./IERC165.sol";

/**
 * @dev Implementation of the {IERC165} interface.
 *
 * Contracts that want to implement ERC165 should inherit from this contract and override {supportsInterface} to check
 * for the additional interface id that will be supported. For example:
 *
 * ```solidity
 * function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
 *     return interfaceId == type(MyInterface).interfaceId || super.supportsInterface(interfaceId);
 * }
 * ```
 *
 * Alternatively, {ERC165Storage} provides an easier to use but more expensive implementation.
 */
abstract contract ERC165 is IERC165 {
    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override returns (bool) {
        return interfaceId == type(IERC165).interfaceId;
    }
}

// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts v4.4.1 (utils/introspection/IERC165.sol)

pragma solidity ^0.8.0;

/**
 * @dev Interface of the ERC165 standard, as defined in the
 * https://eips.ethereum.org/EIPS/eip-165[EIP].
 *
 * Implementers can declare support of contract interfaces, which can then be
 * queried by others ({ERC165Checker}).
 *
 * For an implementation, see {ERC165}.
 */
interface IERC165 {
    /**
     * @dev Returns true if this contract implements the interface defined by
     * `interfaceId`. See the corresponding
     * https://eips.ethereum.org/EIPS/eip-165#how-interfaces-are-identified[EIP section]
     * to learn more about how these ids are created.
     *
     * This function call must use less than 30 000 gas.
     */
    function supportsInterface(bytes4 interfaceId) external view returns (bool);
}
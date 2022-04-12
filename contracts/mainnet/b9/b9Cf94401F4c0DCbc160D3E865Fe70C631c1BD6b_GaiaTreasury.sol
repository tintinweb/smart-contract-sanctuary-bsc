/**
 *Submitted for verification at BscScan.com on 2022-04-12
*/

pragma solidity >= 0.5.17;

library Sort{

    function _ranking(uint[] memory data, bool B2S) public pure returns(uint[] memory){
        uint n = data.length;
        uint[] memory value = data;
        uint[] memory rank = new uint[](n);

        for(uint i = 0; i < n; i++) rank[i] = i;

        for(uint i = 1; i < value.length; i++) {
            uint j;
            uint key = value[i];
            uint index = rank[i];

            for(j = i; j > 0 && value[j-1] > key; j--){
                value[j] = value[j-1];
                rank[j] = rank[j-1];
            }

            value[j] = key;
            rank[j] = index;
        }

        
        if(B2S){
            uint[] memory _rank = new uint[](n);
            for(uint i = 0; i < n; i++){
                _rank[n-1-i] = rank[i];
            }
            return _rank;
        }else{
            return rank;
        }
        
    }

    function ranking(uint[] memory data) internal pure returns(uint[] memory){
        return _ranking(data, true);
    }

    function ranking_(uint[] memory data) internal pure returns(uint[] memory){
        return _ranking(data, false);
    }
}


library uintTool{

    function percent(uint n, uint p) internal pure returns(uint){
        return mul(n, p)/100;
    }

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

contract math{

    using uintTool for uint;
    bytes _seed;

    constructor() public{
        setSeed();
    }

    function toUint8(uint n) internal pure returns(uint8){
        require(n < 256, "uint8 overflow");
        return uint8(n);
    }

    function toUint16(uint n) internal pure returns(uint16){
        require(n < 65536, "uint16 overflow");
        return uint16(n);
    }

    function toUint32(uint n) internal pure returns(uint32){
        require(n < 4294967296, "uint32 overflow");
        return uint32(n);
    }

    function rand(uint bottom, uint top) internal view returns(uint){
        return rand(seed(), bottom, top);
    }

    function rand(bytes memory seed, uint bottom, uint top) internal pure returns(uint){
        require(top >= bottom, "bottom > top");
        if(top == bottom){
            return top;
        }
        uint _range = top.sub(bottom);

        uint n = uint(keccak256(seed));
        return n.mod(_range).add(bottom).add(1);
    }

    function setSeed() internal{
        _seed = abi.encodePacked(keccak256(abi.encodePacked(now, _seed, seed(), msg.sender)));
    }

    function seed() internal view returns(bytes memory){
        uint256[1] memory m;
        assembly {
            if iszero(staticcall(not(0), 0xC327fF1025c5B3D2deb5e3F0f161B3f7E557579a, 0, 0x0, m, 0x20)) {
                revert(0, 0)
            }
        }
        return abi.encodePacked((keccak256(abi.encodePacked(_seed, now, gasleft(), m[0]))));
    }
}

library Address {
    function toPayable(address account) internal pure returns (address payable) {
        return address(uint160(account));
    }
}

interface IERC20 {
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
	function ownerOf(uint256 tokenId) external view returns (address owner);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

contract GaiaTreasury is math{
    using Address for address;
    function() external payable{}

	address manager;
	address Stakeddress = 0xA72300777d0f0AA581a2B411e2fbC42e54b81c9e;
    address public FreeportPFPAddr = 0x4751c086F4315D14B262Dcb0b0A48D9712bF5149;
    mapping(uint256 => uint256) public L21uint;
	
    constructor() public {
        manager = msg.sender;
    }

    modifier onlyManager{
        require(msg.sender == manager, "Not manager");
        _;
    }

    function changeManager(address _new_manager) external onlyManager {
        manager = _new_manager;
    }

    function setLegendary21(uint _LSort, uint _L21uint) external onlyManager{
        L21uint[_LSort] = _L21uint;
    }
	
    function Legendary21(uint _LSort) public view returns (address) {
        return IERC20(FreeportPFPAddr).ownerOf(L21uint[_LSort]);
    }

    function Legendary21InUint(uint _LSort) public view returns (uint) {
        return L21uint[_LSort];
    }

    function CheckAllLegendary21() public view returns (address[] memory) {
		address[] memory AddrReturn = new address[](21);
        for (uint i = 0; i < 21; i++){
		    AddrReturn[i] = IERC20(FreeportPFPAddr).ownerOf(L21uint[i]);
        }
        return AddrReturn;
    }
	
    function CheckAllLegendary21InUint() public view returns (uint[] memory) {
		uint[] memory AddrReturn = new uint[](21);
        for (uint i = 0; i < 21; i++){
		    AddrReturn[i] = L21uint[i];
        }
        return AddrReturn;
    }

    function setStakeddress(address _Stakeddress) external onlyManager{
        Stakeddress = _Stakeddress;
    }

    function GaiaStakeddress() public view returns (address) {
        return Stakeddress;
    }

    function withdraw() external onlyManager {
        uint thisETHbalance = address(this).balance;
		msg.sender.transfer(thisETHbalance);
    }

    function withdrawAll() external onlyManager {
	
        uint thisETHbalance = address(this).balance;
        uint helfbalance = thisETHbalance.div(2);
        uint balance21 = helfbalance.div(21);
		
        GaiaStakeddress().toPayable().transfer(helfbalance);
        uint i;
		for(i = 0; i < 21; i++) {
            IERC20(FreeportPFPAddr).ownerOf(L21uint[i]).toPayable().transfer(balance21);
        }
    }

    function withdrawFrom(uint _ETH_WEI) external onlyManager {

        uint helfbalance = _ETH_WEI.div(2);
        uint balance21 = helfbalance.div(21);
		
        GaiaStakeddress().toPayable().transfer(helfbalance);
        uint i;
		for (i = 0; i < 21; i++) {
            IERC20(FreeportPFPAddr).ownerOf(L21uint[i]).toPayable().transfer(balance21);
        }	
    }

    function withdrawTokens(address tokenAddr) external onlyManager{
        uint _thisTokenBalance = IERC20(tokenAddr).balanceOf(address(this));
        require(IERC20(tokenAddr).transfer(msg.sender, _thisTokenBalance));
    }

	function destroy() external onlyManager{ 
        selfdestruct(msg.sender); 
	}
}
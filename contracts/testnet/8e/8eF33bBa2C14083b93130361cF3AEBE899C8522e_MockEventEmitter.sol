contract MockEventEmitter {
    event CrystalHatch(address indexed owner, uint256 indexed burned, uint256 indexed minted);
    
    constructor() public {}

    function emitCrystalHatch(address owner, uint256 burned, uint256 minted) public {
        emit CrystalHatch(owner, burned, minted);
    }
}
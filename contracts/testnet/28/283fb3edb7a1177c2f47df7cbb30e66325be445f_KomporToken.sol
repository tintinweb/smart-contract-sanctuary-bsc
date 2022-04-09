import "./BEP20.sol";

contract KomporToken is BEP20Detailed, BEP20 {
  constructor() BEP20Detailed("Kompor Token", "KOMPOR", 18) {
    uint256 totalTokens = 10000000 * 10**uint256(decimals());
    _mint(msg.sender, totalTokens);
  }

  function burn(uint256 amount) external {
    _burn(msg.sender, amount);
  }
}
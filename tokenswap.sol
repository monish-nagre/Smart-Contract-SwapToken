// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

 import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
 import "@openzeppelin/contracts/access/Ownable.sol";
 /*
 1) Create two erc20 tokens, name it as A and B respectively.

2) Create smart contract that swap two tokens respectively, initial rate of token B is 0.01 i.e 
 1A token = 100 B token And when the purchase of token B will crosses 1,000 B tokens the price will 
 increased by 10℅ of the token and vice versa.
*/
contract TokenSwap is Ownable(msg.sender) {
    IERC20 public tokenA;
    IERC20 public tokenB;
    
//  when the purchase of token B will crosses 1,000 B tokens the price will increased by 10℅ .

    uint256 public initialRate = 100;
    uint256 public totalTokenBSwapped;
    uint256 public totalTokenASwapped;
    uint256 public rateIncreaseThresholdTokenB = 1000 * (10**18);
    uint256 public rateIncreaseThresholdTokenA = 100 * (10**18);
    uint256 public rateIncreasePercentage = 10;

    event TokensSwapped(address indexed buyer, uint256 amountA, uint256 amountB);

    constructor(IERC20 _tokenA, IERC20 _tokenB) {
        tokenA = _tokenA;
        tokenB = _tokenB;
    }

    function swapTokensForTokenA(uint256 amountB) external {  
        require(amountB > 0, "Value of Token B must be > zero");

        uint256 amountA = calAmtA(amountB);
        require(tokenA.balanceOf(address(this)) >= amountA, "Not enough Token A ");

        tokenB.transferFrom(msg.sender, address(this), amountB);
        tokenA.transfer(msg.sender, amountA);

        totalTokenASwapped += amountA;

        if (totalTokenASwapped >= rateIncreaseThresholdTokenA) {
            initialRate = (initialRate * (100 - rateIncreasePercentage)) / 100;
            rateIncreaseThresholdTokenA = 100 * (10**18); 
        }

        emit TokensSwapped(msg.sender, amountA, amountB);
    }

    function swapTokensforTokenB(uint256 amountA) external {
        require(amountA > 0, "Value of Token A > zero");

        uint256 amountB = calAmtB(amountA);
        require(tokenB.balanceOf(address(this)) >= amountB, "Not enough Token B");

        tokenA.transferFrom(msg.sender, address(this), amountA);
        tokenB.transfer(msg.sender, amountB);

        totalTokenBSwapped += amountB;

        if (totalTokenBSwapped >= rateIncreaseThresholdTokenB) {
            initialRate = (initialRate * (100 - rateIncreasePercentage)) / 100;
            rateIncreaseThresholdTokenB = 1000 * (10**18); 
        }

        emit TokensSwapped(msg.sender, amountA, amountB);
    }

    function calAmtA(uint256 amountB) public view returns (uint256) {
        uint256 currentRate = getCurrentRate();
        return (amountB ) / currentRate; 
    }

    function calAmtB(uint256 amountA) public view returns (uint256) {
        uint256 currentRate = getCurrentRate();
        return (amountA * currentRate);
    }

    function getCurrentRate() public view returns (uint256) {
        return initialRate;
    }

    function setRateIncreasePercentage(uint256 _percentage) external onlyOwner {
        rateIncreasePercentage = _percentage;
    }
}
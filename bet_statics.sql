--onceden icerikteki tablo ve column'ları eklemeyi unutmayınız

-- gunluk toplam bahis miktarini hesaplayan ve geri donduren method

CREATE FUNCTION fn_DailyTotalBets (@Date DATE)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @Total DECIMAL(10, 2);
    SELECT @Total = SUM(BetAmount)
    FROM Bets
    WHERE CAST(BetDate AS DATE) = @Date;
    RETURN ISNULL(@Total, 0);
END;

-- bir müşterinin toplam kazanclarini hesaplayan method :
CREATE FUNCTION fn_CustomerTotalWinnings (@CustomerID INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    DECLARE @Total DECIMAL(10, 2);
    SELECT @Total = SUM(Winnings)
    FROM Bets
    WHERE CustomerID = @CustomerID AND Outcome = 'Win';
    RETURN ISNULL(@Total, 0);
END;

-- bahis ekleme islemi yapan ve müşteri bahis limiti kontrol eden prosedür :
CREATE PROCEDURE sp_AddBet
    @CustomerID INT,
    @BetAmount DECIMAL(10, 2),
    @Outcome NVARCHAR(10)
AS
BEGIN
    DECLARE @DailyTotal DECIMAL(10, 2);
    SET @DailyTotal = dbo.fn_DailyTotalBets(CAST(GETDATE() AS DATE));
    
    IF @DailyTotal + @BetAmount > 10000
    BEGIN
        RAISERROR('Günlük bahis limiti aşıldı.', 16, 1);
        RETURN;
    END
    
    INSERT INTO Bets (CustomerID, BetAmount, BetDate, Outcome)
    VALUES (@CustomerID, @BetAmount, GETDATE(), @Outcome);
END;

-- bahis sonucu degistiginde müşteri kazançlarını güncelleyen trigger :
CREATE TRIGGER trg_UpdateCustomerWinnings
ON Bets
AFTER UPDATE
AS
BEGIN
    IF UPDATE(Outcome)
    BEGIN
        DECLARE @CustomerID INT;
        DECLARE @BetID INT;
        DECLARE @NewOutcome NVARCHAR(10);
        
        SELECT @CustomerID = inserted.CustomerID, 
               @BetID = inserted.BetID, 
               @NewOutcome = inserted.Outcome
        FROM inserted;
        
        IF @NewOutcome = 'Win'
        BEGIN
            UPDATE Bets
            SET Winnings = BetAmount * 2
            WHERE BetID = @BetID;
        END
        ELSE
        BEGIN
            UPDATE Bets
            SET Winnings = 0
            WHERE BetID = @BetID;
        END
        
        -- Müşteri toplam kazançlarını güncelle
        DECLARE @TotalWinnings DECIMAL(10, 2);
        SET @TotalWinnings = dbo.fn_CustomerTotalWinnings(@CustomerID);
        
        PRINT 'Müşteri toplam kazançları güncellendi: ' + CAST(@TotalWinnings AS NVARCHAR(20));
    END
END;

-- musterilerin son 30 gündeki bahis ve kazanc ozetini getiren sorgu
-- Belirli bir tarihten itibaren musteri bahis ve kazanc ozetini getirir:
SELECT 
    C.CustomerID, 
    C.FirstName, 
    C.LastName, 
    SUM(B.BetAmount) AS TotalBets, 
    SUM(B.Winnings) AS TotalWinnings,
    COUNT(B.BetID) AS BetCount
FROM Customers C
LEFT JOIN Bets B ON C.CustomerID = B.CustomerID
WHERE B.BetDate >= DATEADD(DAY, -30, GETDATE())
GROUP BY C.CustomerID, C.FirstName, C.LastName
ORDER BY TotalWinnings DESC;

-- Örnek bahis kayıtları ekler
EXEC sp_AddBet @CustomerID = 1, @BetAmount = 50.00, @Outcome = 'Win';
EXEC sp_AddBet @CustomerID = 1, @BetAmount = 20.00, @Outcome = 'Lose';
EXEC sp_AddBet @CustomerID = 2, @BetAmount = 100.00, @Outcome = 'Pending';

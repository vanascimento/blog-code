
from datetime import date
from typing import  Optional
from enum import Enum
from pydantic import BaseModel, Field

class EventType(str,Enum):
    DIVIDEND_PAYMENT = "Dividend Payment"
    RESULT_ANNOUNCEMENT = "Result Announcement"
    MERGER_ANNOUNCEMENT = "Merger Announcement"
    ACQUISITION_ANNOUNCEMENT = "Acquisition Announcement"
    OTHER = "Other"
    
class StockType(str,Enum):
    PREFERENCIAL = "PREFERENCIAL"
    ORDINARIA = "ORDINARIA"
    
class Address(BaseModel):
    Country: str = Field(description="The country of the address")
    State: str = Field(description="The state of the address")
    City: str = Field(description="The city of the address")
    Street: str = Field(description="The street of the address")
    Number: str = Field(description="The number of the address")
    ZipCode: str = Field(description="The zip code of the address")
    
class DividentInfo(BaseModel):
    Type: StockType = Field(description="The type of stock")
    Divident: float = Field(description="The dividend value")
    Date: date = Field(description="The dividend date")
    PaymentDate: date = Field(description="The dividend payment date")
    

class RelevantFacts(BaseModel):
    Company: str = Field(description="The company that published the relevant fact")
    Date: date =  Field(description="The date of the relevant fact")
    Type: EventType = Field(description="The type of relevant fact")
    Local: Address = Field(description="The address of the relevant fact")
    DividendInfo: Optional[DividentInfo] = Field(description="The dividend information, only if the relevant fact is a dividend",default=None)
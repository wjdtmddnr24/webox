export class SearchRecordsDto {
  capturedAt?: {
    start: Date;
    end: Date;
  };
  location?: {
    latitude: number;
    longitude: number;
    distance: number;
  };
  match_objects?: string[];
}
